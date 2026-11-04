local MODULE, NS = ...
local GoldTracker = NS.GoldTracker
local Diagnostics = NS.TSMRealmDiagnostics

-- This file must execute before AppHelper's AppData.lua. Do not defer the
-- hook until PLAYER_LOGIN or depend on AppHelper (which would load it first).
-- Keep strings in memory only; never change TSM's receiver or saved variables.
local TAGS = {
    AUCTIONDB_NON_COMMODITY_DATA = "current",
    AUCTIONDB_NON_COMMODITY_SCAN_STAT = "market",
    AUCTIONDB_NON_COMMODITY_HISTORICAL = "historical",
}
local state = { realms = {}, calls = 0, captured = 0, bytes = 0, peakBytes = 0, errors = 0 }
GoldTracker.tsmRealmCapture = state
state.diagnostics = Diagnostics

local function IsLoaded(name)
    local fn = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    return type(fn) == "function" and fn(name) and true or false
end

local function Version(name)
    local fn = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return (type(fn) == "function" and fn(name, "Version")) or "unavailable"
end

local function Print(message)
    GoldTracker:Print(message, "commands")
end

local function Capture(tag, realm, payload)
    state.calls = state.calls + 1
    if not TAGS[tag] or type(realm) ~= "string" or type(payload) ~= "string" then return end
    local datasets = state.realms[realm]
    if not datasets then
        datasets = {}
        state.realms[realm] = datasets
    end
    local previous = datasets[TAGS[tag]]
    state.bytes = state.bytes - (previous and #previous.payload or 0) + #payload
    state.peakBytes = math.max(state.peakBytes, state.bytes)
    datasets[TAGS[tag]] = {
        payload = payload,
        timestamp = tonumber(payload:match("downloadTime=(%d+)")),
    }
    state.captured = state.captured + 1
end

local function InstallHook()
    if state.hooked then return end
    if type(TSM_APPHELPER_LOAD_DATA) ~= "function" then
        state.reason = "TSM receiver unavailable"
        return
    end
    if type(hooksecurefunc) ~= "function" then
        state.reason = "hooksecurefunc unavailable"
        return
    end
    state.helperLoadedAtHook = IsLoaded("TradeSkillMaster_AppHelper")
    local ok, err = pcall(hooksecurefunc, "TSM_APPHELPER_LOAD_DATA", function(...)
        local captured, captureError = Diagnostics.Run("capture", Capture, ...)
        if not captured then
            state.errors = state.errors + 1
            state.lastError = tostring(captureError)
        end
    end)
    state.hooked = ok
    if ok then state.reason = nil else state.reason = tostring(err) end
end

local function SortedRealms()
    local realms = {}
    for realm in pairs(state.realms) do realms[#realms + 1] = realm end
    table.sort(realms)
    return realms
end

local function Timestamp(value)
    return value and date("%Y-%m-%d %H:%M:%S", value) or "unknown"
end

local function Money(value)
    if not value or value <= 0 then return "no price" end
    return string.format("%dg %ds %dc", math.floor(value / 10000), math.floor(value / 100) % 100, value % 100)
end

local function NormalizeItem(query)
    if type(query) == "number" then query = tostring(query) end
    if type(query) ~= "string" then return nil end
    query = (query or ""):match("^%s*(.-)%s*$")
    local id = query:match("^%d+$") or query:match("|Hitem:(%d+):") or query:match("^item:(%d+)")
    if id and tonumber(id) > 0 then return "i:" .. id end
    if query:match("^i:%d+[:%w%-]*$") or query:match("^p:%d+[:%w%-]*$") then return query end
end

local function ReadFields(dataset, itemString)
    if not dataset then return nil end
    local payload = dataset.payload
    local fieldsText = payload:match("fields={(.-)}")
    if not fieldsText then return nil end
    local needle = "{\"" .. itemString .. "\","
    local start = payload:find(needle, 1, true)
    if not start and itemString:match("^i:%d+$") then
        needle = "{" .. itemString:sub(3) .. ","
        start = payload:find(needle, 1, true)
    end
    if not start then return nil end
    local finish = payload:find("}", start, true)
    if not finish then return nil end
    local encoded = payload:sub(start + #needle, finish - 1)
    local values, index = {}, 1
    for token in encoded:gmatch("[^,]+") do
        -- Split long numbers as WoW's base conversion can truncate at 32 bits.
        local value
        if #token > 6 then
            local low, high = tonumber(token:sub(-6), 32), tonumber(token:sub(1, -7), 32)
            value = low and high and (low + high * 1073741824) or nil
        else
            value = tonumber(token, 32)
        end
        if not value then return nil end
        values[index] = value
        index = index + 1
    end
    local result, fieldIndex = {}, 0
    for field in fieldsText:gmatch('"([^"]+)"') do
        if fieldIndex > 0 then result[field] = values[fieldIndex] end
        fieldIndex = fieldIndex + 1
    end
    return result
end

local function GetItemValues(realm, query)
    local itemString = NormalizeItem(query)
    local datasets = state.realms[realm]
    if not itemString or not datasets then return nil end
    local result = { itemString = itemString, timestamps = {} }
    local found = false
    for _, key in ipairs({ "current", "market", "historical" }) do
        local values = ReadFields(datasets[key], itemString)
        if values then
            for field, value in pairs(values) do result[field] = value end
            result.timestamps[key] = datasets[key].timestamp
            found = true
        end
    end
    return found and result or nil
end

function GoldTracker:GetCapturedTSMRealms()
    return SortedRealms()
end

function GoldTracker:GetCapturedTSMRealmRevision()
    return state.captured
end

function GoldTracker:GetCapturedTSMRealmItemValues(realm, query)
    local ok, value = Diagnostics.Run("query", GetItemValues, realm, query)
    if ok then return value end
    state.errors = state.errors + 1
    state.lastError = tostring(value)
    return nil
end

function GoldTracker:BuildTSMRealmCaptureReport(query)
    local realms = SortedRealms()
    local lines = {
        "GGT TSM Realm Prices v1 (optional module; session memory only)",
        "TSM=" .. Version("TradeSkillMaster") .. "; AppHelper=" .. Version("TradeSkillMaster_AppHelper"),
        "Current realm=" .. (type(GetRealmName) == "function" and GetRealmName() or "unknown"),
        "Hook=" .. (state.hooked and "installed" or "NOT installed")
            .. "; AppHelper already loaded at hook=" .. (not state.hooked and "unknown" or (state.helperLoadedAtHook and "YES (too late)" or "no")),
        string.format("Observed calls=%d; non-commodity payloads=%d; realms=%d; retained payload=%.1f KiB; payload high-water=%.1f KiB; errors=%d",
            state.calls, state.captured, #realms, state.bytes / 1024, state.peakBytes / 1024, state.errors),
    }
    if state.reason then lines[#lines + 1] = "Hook issue: " .. state.reason end
    if state.lastError then lines[#lines + 1] = "Capture error: " .. state.lastError end
    for _, realm in ipairs(realms) do
        local parts = {}
        for _, key in ipairs({ "current", "market", "historical" }) do
            local entry = state.realms[realm][key]
            parts[#parts + 1] = key .. "=" .. (entry and (Timestamp(entry.timestamp) .. ", " .. #entry.payload .. " bytes") or "MISSING")
        end
        lines[#lines + 1] = realm .. ": " .. table.concat(parts, "; ")
    end
    if #realms == 0 then
        lines[#lines + 1] = "No realm payloads captured. Send this report to diagnose startup order."
    elseif #realms == 1 then
        lines[#lines + 1] = "One realm captured. Add another Retail realm in the TSM desktop app, wait for its download, then /reload."
    end
    if query and query ~= "" then
        local itemString = NormalizeItem(query)
        if itemString then
            lines[#lines + 1] = "Item=" .. itemString .. " (exact item key; no variant fallback)"
            for _, realm in ipairs(realms) do
                local values = self:GetCapturedTSMRealmItemValues(realm, itemString)
                if values then
                    lines[#lines + 1] = realm .. ": min=" .. Money(values.minBuyout)
                        .. "; market=" .. Money(values.marketValue) .. "; recent=" .. Money(values.marketValueRecent)
                        .. "; historical=" .. Money(values.historical)
                        .. "; auctions=" .. tostring(values.numAuctions or "unknown")
                else
                    lines[#lines + 1] = realm .. ": item absent from captured non-commodity data"
                end
            end
        else
            lines[#lines + 1] = "Invalid item. Use an item ID, item link, or TSM item string."
        end
    end
    lines[#lines + 1] = Diagnostics.Report()
    lines[#lines + 1] = "/gttsm item <itemID> | copy [itemID] | status | profile on/off | reset"
    return table.concat(lines, "\n")
end

local function ShowCopy(report)
    local frame = state.copyFrame
    if not frame then
        frame = CreateFrame("Frame", "GGTTSMCaptureReport", UIParent, "BasicFrameTemplateWithInset")
        frame:SetSize(700, 430)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        frame.TitleText:SetText("GGT TSM Realm Prices - Ctrl+A, Ctrl+C to copy")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 14, -36)
        scroll:SetPoint("BOTTOMRIGHT", -32, 14)
        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(640)
        edit:SetHeight(360)
        edit:SetAutoFocus(false)
        edit:SetScript("OnEscapePressed", function() frame:Hide() end)
        scroll:SetScrollChild(edit)
        frame.edit = edit
        frame.scroll = scroll
        state.copyFrame = frame
    end
    frame:Show()
    local _, newlines = report:gsub("\n", "\n")
    frame.edit:SetHeight(math.max(360, (newlines + 1) * 18))
    frame.edit:SetText(report)
    frame.scroll:UpdateScrollChildRect()
    frame.scroll:SetVerticalScroll(0)
    frame.edit:SetFocus()
    frame.edit:HighlightText()
end

-- Run immediately, while TSM (our dependency) is loaded and AppHelper should
-- still be pending. A separate frame also catches a delayed TSM load, but cannot
-- recover payloads that arrived before this file executed.
InstallHook()
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == MODULE then
        Diagnostics.LoadSettings()
    elseif event == "ADDON_LOADED" and name == "TradeSkillMaster" then
        InstallHook()
    elseif event == "PLAYER_LOGIN" then
        if C_Timer and C_Timer.After then C_Timer.After(2, Diagnostics.SampleMemory) else Diagnostics.SampleMemory() end
        if events.UnregisterAllEvents then events:UnregisterAllEvents() end
    end
end)

SLASH_GGTTSMCAPTURE1 = "/gttsm"
SlashCmdList.GGTTSMCAPTURE = function(message)
    local command, args = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()
    if command == "profile" then
        if args ~= "on" and args ~= "off" then Print("Usage: /gttsm profile on|off"); return end
        Diagnostics.SetDetailed(args == "on")
        Print("Detailed profiling " .. (Diagnostics.detailed and "enabled" or "disabled") .. ". Preference saved; /reload to measure startup capture. Capture timing and payload counters stay available.")
        return
    elseif command == "reset" then
        Diagnostics.Reset()
        Print("Timing/allocation metrics and sampled memory maximum reset; captured prices retained.")
        return
    end
    if command == "copy" then
        ShowCopy(GoldTracker:BuildTSMRealmCaptureReport(args ~= "" and args or state.lastQuery))
        return
    end
    local query = command == "item" and args or (command ~= "" and command ~= "status" and message or nil)
    if query then state.lastQuery = query end
    local report = GoldTracker:BuildTSMRealmCaptureReport(query)
    for line in report:gmatch("[^\n]+") do Print(line) end
end
