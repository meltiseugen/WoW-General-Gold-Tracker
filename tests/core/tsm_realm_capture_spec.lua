local loader = require("tests.helpers.addon_loader")

local function with_capture(options, callback)
    options = options or {}
    local originalCalls, kept, messages, frames = {}, {}, {}, {}
    local clock, loads, samples, tickers = 0, 0, 0, {}
    local globals = {
        GeneralGoldTrackerCatalogNamespace = false,
        GGTTSMRealmDataSettings = false,
        C_AddOnProfiler = false,
        GetTimePreciseSec = function() clock = clock + 0.001; return clock end,
        C_AddOns = {
            IsAddOnLoaded = function() return options.late == true end,
            GetAddOnMetadata = function() return "test" end,
            GetAddOnEnableState = function() return options.disabled and 0 or 2 end,
            UpdateAddOnMemoryUsage = function() samples = samples + 1 end,
            GetAddOnMemoryUsage = function() return options.memory or 100 end,
        },
        GetRealmName = function() return "Current" end,
        date = function(_, timestamp) return tostring(timestamp) end,
        DEFAULT_CHAT_FRAME = { AddMessage = function(_, text) messages[#messages + 1] = text end },
        SlashCmdList = {},
        SLASH_GGTTSMCAPTURE1 = false,
        TSM_APPHELPER_LOAD_DATA = function(tag, realm, data)
            originalCalls[#originalCalls + 1] = { tag, realm, data }
            if realm == "Current" then kept[tag] = data end
            return "original result"
        end,
        CreateFrame = function()
            local frame = {
                RegisterEvent = function() end,
                SetScript = function(self, _, handler) self.handler = handler end,
            }
            frames[#frames + 1] = frame
            return frame
        end,
        hooksecurefunc = function(name, callbackFn)
            local original = _G[name]
            _G[name] = function(...)
                local result = original(...)
                callbackFn(...)
                return result
            end
        end,
        C_Timer = {
            After = function(_, fn) fn() end,
            NewTicker = function(_, fn)
                local ticker = { callback = fn, Cancel = function(self) self.cancelled = true end }
                tickers[#tickers + 1] = ticker
                return ticker
            end,
        },
    }
    if options.missing then globals.TSM_APPHELPER_LOAD_DATA = false end
    if options.native then
        globals.C_AddOnProfiler = {
            MeasureCall = function(fn, ...)
                local result = fn(...)
                if options.profilerError then error("profiler failed after call") end
                return { elapsedMilliseconds = 0.25, allocatedBytes = 2048, deallocatedBytes = 1024 }, result
            end,
        }
    end
    loader.with_globals(globals, function()
        local addon, ns = loader.load_module("Core/Namespace.lua", {})
        addon.db = { enableChatLogging = true }
        loader.load_module("Core/TSMRealmData.lua", addon, ns)
        GeneralGoldTrackerCatalogNamespace = ns
        C_AddOns.LoadAddOn = function(name)
            loads = loads + 1
            if options.uninstalled then return nil, "MISSING" end
            if options.noTSM then return nil, "DEP_MISSING" end
            local root = "Data/" .. name .. "/"
            local private = {}
            for line in io.lines(root .. name .. ".toc") do
                line = line:gsub("\r", "")
                if line:match("%.lua$") then assert(loadfile(root .. line))(name, private) end
            end
            return true
        end
        addon:InitializeTSMRealmData()
        callback(addon, originalCalls, kept, messages, frames, {
            loads = function() return loads end,
            samples = function() return samples end,
            tickers = tickers,
        })
    end)
end

local CURRENT = 'return {downloadTime=123,fields={"itemString","minBuyout","numAuctions","marketValueRecent"},data={{123,9OG,2,JH0},{"i:123::i100",V8,1,V8}}}'
local MARKET = 'return {downloadTime=124,fields={"itemString","marketValue"},data={{123,UG0}}}'
local HISTORICAL = 'return {downloadTime=125,fields={"itemString","historical"},data={{123,VVVVVVVV}}}'

describe("Optional TSM realm data module", function()
    it("captures discarded realms while preserving TSM calls and return values", function()
        with_capture({}, function(addon, calls, kept)
            assert.equals("original result", TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Current", CURRENT))
            assert.equals("original result", TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT))
            assert.equals(2, #calls)
            assert.equals(CURRENT, kept.AUCTIONDB_NON_COMMODITY_DATA)
            assert.equals(CURRENT, addon.tsmRealmCapture.realms.Other.current.payload)
            assert.equals(2, addon.tsmRealmCapture.captured)
            assert.is_false(addon.tsmRealmCapture.helperLoadedAtHook)
            assert.is_nil(addon.tsmRealmCapture.reason)
        end)
    end)

    it("decodes current, market, historical and long base32 prices", function()
        with_capture({}, function(addon)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_SCAN_STAT", "Other", MARKET)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_HISTORICAL", "Other", HISTORICAL)
            local value = addon:GetCapturedTSMRealmItemValues("Other", "123")
            assert.equals(10000, value.minBuyout)
            assert.equals(20000, value.marketValueRecent)
            assert.equals(31232, value.marketValue)
            assert.equals(1099511627775, value.historical)
            assert.equals(2, value.numAuctions)
            assert.equals(123, value.timestamps.current)
            assert.equals(124, value.timestamps.market)
            assert.equals(125, value.timestamps.historical)
            assert.same({ "Other" }, addon:GetCapturedTSMRealms())
            assert.equals(3, addon:GetCapturedTSMRealmRevision())
        end)
    end)

    it("keeps exact variants separate and represents missing prices as absent", function()
        with_capture({}, function(addon)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            assert.equals(1000, addon:GetCapturedTSMRealmItemValues("Other", "i:123::i100").minBuyout)
            assert.is_nil(addon:GetCapturedTSMRealmItemValues("Other", "i:123::i999"))
            assert.is_nil(addon:GetCapturedTSMRealmItemValues("Other", "999"))
            assert.is_nil(addon:GetCapturedTSMRealmItemValues("Unknown realm", "123"))
        end)
    end)

    it("ignores commodity and regional payloads and replaces duplicate realm tags", function()
        with_capture({}, function(addon)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_COMMODITY_DATA", "EU", CURRENT)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_REGION_STAT", "EU", MARKET)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            assert.is_nil(addon.tsmRealmCapture.realms.EU)
            assert.equals(4, addon.tsmRealmCapture.calls)
            assert.equals(#CURRENT, addon.tsmRealmCapture.bytes)
        end)
    end)

    it("reports unavailable and late hooks honestly", function()
        with_capture({ missing = true }, function(addon)
            assert.is_nil(addon.tsmRealmCapture.hooked)
            assert.matches("NOT installed", addon:BuildTSMRealmCaptureReport())
        end)
        with_capture({ late = true }, function(addon)
            assert.is_true(addon.tsmRealmCapture.helperLoadedAtHook)
            assert.matches("YES %(too late%)", addon:BuildTSMRealmCaptureReport())
        end)
    end)

    it("contains capture errors without changing the original TSM result", function()
        with_capture({}, function(addon)
            addon.tsmRealmCapture.realms = false
            assert.equals("original result", TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT))
            assert.equals(1, addon.tsmRealmCapture.errors)
        end)
    end)

    it("routes explicit diagnostic reports through the master and command switches", function()
        with_capture({}, function(addon, _, _, messages, frames)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            addon.db.enableChatLogging = false
            SlashCmdList.GGTTSMCAPTURE("item 123")
            assert.equals(0, #messages)
            addon.db.enableChatLogging = true
            addon.db.chatLogCommands = false
            SlashCmdList.GGTTSMCAPTURE("item 123")
            assert.equals(0, #messages)
            addon.db.chatLogCommands = true
            SlashCmdList.GGTTSMCAPTURE("item 123")
            assert.matches("min=1g 0s 0c", table.concat(messages, "\n"))
            assert.matches("market=no price", table.concat(messages, "\n"))
            assert.equals("123", addon.tsmRealmCapture.lastQuery)
            local beforeLogin = #messages
            frames[1].handler(nil, "PLAYER_LOGIN")
            assert.equals(beforeLogin, #messages)
        end)
    end)

    it("leaves no capture hook or payload state when disabled and keeps normal TSM pricing", function()
        with_capture({ disabled = true }, function(addon, _, _, _, frames, runtime)
            assert.is_nil(addon.tsmRealmCapture)
            assert.equals(0, #frames)
            assert.equals(0, runtime.loads())
            assert.is_nil(addon:GetCapturedTSMRealmItemValues("Other", "123"))
            assert.same({}, addon:GetCapturedTSMRealms())
            assert.equals(0, addon:GetCapturedTSMRealmRevision())
            assert.matches("disabled", addon:BuildTSMRealmCaptureReport())
            loader.with_globals({ TSM_API = { GetCustomPriceValue = function() return 98765 end } }, function()
                loader.load_module("Tracking/Valuation.lua", addon)
                assert.equals(98765, addon:GetTSMItemValueForItemID("DBMarket", 123, true))
            end)
        end)
    end)

    it("keeps the main addon usable with missing module or missing TSM", function()
        for _, options in ipairs({ { uninstalled = true }, { noTSM = true } }) do
            with_capture(options, function(addon, _, _, _, frames)
                assert.is_nil(addon.tsmRealmCapture)
                assert.equals(0, #frames)
                assert.is_nil(addon:GetCapturedTSMRealmItemValues("Other", "123"))
                assert.matches("unavailable", addon:BuildTSMRealmCaptureReport())
            end)
        end
    end)

    it("records capture and query timings without detailed profiling or timers", function()
        with_capture({}, function(addon, _, _, _, _, runtime)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            addon:GetCapturedTSMRealmItemValues("Other", "123")
            local diagnostics = addon.tsmRealmCapture.diagnostics
            assert.equals(1, diagnostics.capture.count)
            assert.equals(1, diagnostics.query.count)
            assert.is_true(diagnostics.capture.totalMs > 0)
            assert.is_true(diagnostics.query.maxMs > 0)
            assert.is_false(diagnostics.detailed)
            assert.equals(0, #runtime.tickers)
            assert.equals(0, runtime.samples())
        end)
    end)

    it("samples attributed memory separately from payload bytes and keeps the sampled maximum", function()
        local options = { memory = 120 }
        with_capture(options, function(addon)
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            addon:BuildTSMRealmCaptureReport()
            options.memory = 80
            local report = addon:BuildTSMRealmCaptureReport()
            assert.matches("memory=80.0 KiB; highest sample=120.0 KiB", report)
            assert.equals(#CURRENT, addon.tsmRealmCapture.bytes)
            assert.equals(#CURRENT, addon.tsmRealmCapture.peakBytes)
        end)
    end)

    it("enables native call measurements and stops sampling when detailed profiling is disabled", function()
        with_capture({ native = true }, function(addon, _, _, _, _, runtime)
            SlashCmdList.GGTTSMCAPTURE("profile on")
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            addon:GetCapturedTSMRealmItemValues("Other", "123")
            local diagnostics = addon.tsmRealmCapture.diagnostics
            assert.equals(1, diagnostics.capture.measured)
            assert.equals(2048, diagnostics.query.allocated)
            assert.equals(1024, diagnostics.query.freed)
            assert.equals(0.25, diagnostics.query.totalMs)
            assert.equals(1, #runtime.tickers)
            SlashCmdList.GGTTSMCAPTURE("profile off")
            assert.is_true(runtime.tickers[1].cancelled)
            assert.is_nil(diagnostics.ticker)
            SlashCmdList.GGTTSMCAPTURE("reset")
            assert.equals(0, diagnostics.query.count)
            assert.equals(#CURRENT, addon.tsmRealmCapture.bytes)
            assert.equals(10000, addon:GetCapturedTSMRealmItemValues("Other", "123").minBuyout)
        end)
    end)

    it("does not repeat a function when the native profiler fails after executing it", function()
        with_capture({ native = true, profilerError = true }, function(addon, calls)
            SlashCmdList.GGTTSMCAPTURE("profile on")
            assert.equals("original result", TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT))
            assert.equals(1, #calls)
            assert.equals(1, addon.tsmRealmCapture.captured)
            assert.equals(1, addon.tsmRealmCapture.errors)
        end)
    end)

    it("restores profiling before AppHelper data and saves only a boolean preference", function()
        with_capture({ native = true }, function(addon, _, _, _, frames)
            GGTTSMRealmDataSettings = { detailed = true, unwantedPayload = CURRENT }
            frames[1].handler(nil, "ADDON_LOADED", "General-Gold-Tracker_TSMRealmData")
            TSM_APPHELPER_LOAD_DATA("AUCTIONDB_NON_COMMODITY_DATA", "Other", CURRENT)
            assert.equals(1, addon.tsmRealmCapture.diagnostics.capture.measured)
            assert.same({ detailed = true }, GGTTSMRealmDataSettings)
            SlashCmdList.GGTTSMCAPTURE("profile off")
            assert.same({ detailed = false }, GGTTSMRealmDataSettings)
        end)
    end)
end)
