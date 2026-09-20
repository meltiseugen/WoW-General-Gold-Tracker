local loader = require("tests.helpers.addon_loader")

local function load_valuation(addon, globals)
    return loader.with_globals(globals or {}, function()
        return loader.load_module("Tracking/Valuation.lua", addon)
    end)
end

describe("Tracking/Valuation", function()
    it("uses TSM ToItemString first and falls back to item ID strings", function()
        local calls = {}
        local addon = {
            GetTSMItemStringFromLink = function()
                return "i:12345"
            end,
            Print = function() end,
        }

        loader.with_globals({
            TSM_API = {
                ToItemString = function()
                    return "p:555"
                end,
                GetCustomPriceValue = function(source, item_string)
                    calls[#calls + 1] = source .. ":" .. item_string
                    if item_string == "i:12345" then
                        return 123.6
                    end
                    return 0
                end,
            },
        }, function()
            addon = loader.load_module("Tracking/Valuation.lua", addon)
            assert.equals(124, addon:GetTSMItemValue("DBMarket", "|Hitem:12345::::::::|h[Test]|h"))
            assert.same({ "DBMarket:p:555", "DBMarket:i:12345" }, calls)
        end)
    end)

    it("prints the unavailable TSM warning only once unless a value later succeeds", function()
        local messages = {}
        local addon = {
            GetTSMItemStringFromLink = function()
                return "i:12345"
            end,
            Print = function(_, message)
                messages[#messages + 1] = message
            end,
        }

        addon = load_valuation(addon, { TSM_API = nil })

        assert.equals(0, addon:GetTSMItemValue("DBMarket", "|Hitem:12345::::::::|h[Test]|h"))
        assert.equals(0, addon:GetTSMItemValue("DBMarket", "|Hitem:12345::::::::|h[Test]|h"))
        assert.equals(1, #messages)
    end)

    it("falls back from the current source to the configured fallback source for loot values", function()
        local addon = {
            VALUE_SOURCE_BY_ID = {
                PRIMARY = { id = "PRIMARY", label = "Primary", tsmKey = "PrimaryKey" },
                FALLBACK = { id = "FALLBACK", label = "Fallback", tsmKey = "FallbackKey" },
            },
            GetCurrentValueSource = function(self)
                return self.VALUE_SOURCE_BY_ID.PRIMARY
            end,
            GetFallbackValueSource = function(self)
                return self.VALUE_SOURCE_BY_ID.FALLBACK
            end,
            GetTSMItemValue = function(_, source)
                return source == "FallbackKey" and 45000 or 0
            end,
            GetVendorItemValue = function()
                return 0
            end,
        }

        addon = load_valuation(addon)
        addon.GetTSMItemValue = function(_, source)
            return source == "FallbackKey" and 45000 or 0
        end

        local value, source_id, source_label = addon:GetItemUnitValue("|Hitem:12345::::::::|h[Test]|h")

        assert.equals(45000, value)
        assert.equals("FALLBACK", source_id)
        assert.equals("Fallback", source_label)
    end)

    it("uses the shared ordered fallback chain only when the preferred source is missing", function()
        local calls = {}
        local addon = {
            VALUE_SOURCE_BY_ID = {
                PRIMARY = { id = "PRIMARY", label = "Primary", tsmKey = "PrimaryKey" },
                FIRST = { id = "FIRST", label = "First fallback", tsmKey = "FirstKey" },
                SECOND = { id = "SECOND", label = "Second fallback", tsmKey = "SecondKey" },
            },
            GetCurrentValueSource = function(self)
                return self.VALUE_SOURCE_BY_ID.PRIMARY
            end,
            GetValueSourceResolutionOrder = function()
                return { "PRIMARY", "FIRST", "SECOND" }
            end,
            GetTSMItemValue = function(_, source)
                calls[#calls + 1] = source
                return source == "SecondKey" and 55000 or 0
            end,
            GetVendorItemValue = function()
                return 0
            end,
        }

        addon = load_valuation(addon)
        addon.GetTSMItemValue = function(_, source)
            calls[#calls + 1] = source
            return source == "SecondKey" and 55000 or 0
        end
        local value, source_id, source_label, was_fallback =
            addon:ResolveItemUnitValue("PRIMARY", "|Hitem:12345::::::::|h[Test]|h")

        assert.equals(55000, value)
        assert.equals("SECOND", source_id)
        assert.equals("Second fallback", source_label)
        assert.is_true(was_fallback)
        assert.same({ "PrimaryKey", "FirstKey", "SecondKey" }, calls)

        calls = {}
        addon.GetTSMItemValue = function(_, source)
            calls[#calls + 1] = source
            return source == "PrimaryKey" and 32000 or 0
        end
        value, source_id, source_label, was_fallback =
            addon:ResolveItemUnitValue("PRIMARY", "|Hitem:12345::::::::|h[Test]|h")

        assert.equals(32000, value)
        assert.equals("PRIMARY", source_id)
        assert.equals("Primary", source_label)
        assert.is_false(was_fallback)
        assert.same({ "PrimaryKey" }, calls)
    end)

    it("reads coordinates from Retail map-position objects with a custom Lua type", function()
        local native_type = type
        local position = {
            GetXY = function()
                return 0.572, 0.228
            end,
        }
        local addon = load_valuation({
            session = {
                mapID = 100,
                mapName = "Hellfire Peninsula",
                zoneName = "Hellfire Peninsula",
            },
        })

        local location
        loader.with_globals({
            type = function(value)
                if value == position then
                    return "vector2"
                end
                return native_type(value)
            end,
            C_Map = {
                GetPlayerMapPosition = function()
                    return position
                end,
            },
        }, function()
            location = addon:GetCurrentSessionLootLocationData()
        end)

        assert.equals(100, location.mapID)
        assert.equals(0.572, location.mapX)
        assert.equals(0.228, location.mapY)
        assert.equals("live", location.coordinateSource)
    end)

    it("prefers the live best map over a stale session map", function()
        local requestedMaps = {}
        local addon = load_valuation({
            session = {
                mapID = 100,
                mapName = "Old Map",
                zoneName = "Current Zone",
            },
            GetMapLocationDetails = function(_, mapID)
                return {
                    mapID = mapID,
                    mapName = mapID == 200 and "Current Map" or "Old Map",
                }
            end,
        })

        local location
        loader.with_globals({
            C_Map = {
                GetBestMapForUnit = function()
                    return 200
                end,
                GetPlayerMapPosition = function(mapID)
                    requestedMaps[#requestedMaps + 1] = mapID
                    return {
                        GetXY = function()
                            return 0.25, 0.75
                        end,
                    }
                end,
            },
        }, function()
            location = addon:GetCurrentSessionLootLocationData()
        end)

        assert.same({ 200 }, requestedMaps)
        assert.equals(200, location.mapID)
        assert.equals("Current Map", location.mapName)
        assert.equals(0.25, location.mapX)
        assert.equals(0.75, location.mapY)
        assert.equals("live", location.coordinateSource)
    end)

    it("uses only a recent cached coordinate from the same map", function()
        local now = 10
        local livePosition = true
        local addon = load_valuation({
            session = {
                mapID = 100,
                mapName = "Hellfire Peninsula",
                zoneName = "Hellfire Peninsula",
            },
        })

        loader.with_globals({
            GetTime = function()
                return now
            end,
            C_Map = {
                GetBestMapForUnit = function()
                    return 100
                end,
                GetPlayerMapPosition = function()
                    if not livePosition then
                        return nil
                    end
                    return {
                        GetXY = function()
                            return 0.4, 0.6
                        end,
                    }
                end,
            },
        }, function()
            local first = addon:GetCurrentSessionLootLocationData()
            assert.equals("live", first.coordinateSource)

            livePosition = false
            now = 12
            local cached = addon:GetCurrentSessionLootLocationData()
            assert.equals("cached", cached.coordinateSource)
            assert.equals(0.4, cached.mapX)
            assert.equals(0.6, cached.mapY)

            now = 20
            local expired = addon:GetCurrentSessionLootLocationData()
            assert.equals("unavailable", expired.coordinateSource)
            assert.is_nil(expired.mapX)
            assert.is_nil(expired.mapY)
        end)
    end)

    it("retries missing loot coordinates and patches the original entry", function()
        local queued = {}
        local attempts = 0
        local finished
        local addon = load_valuation({
            diagnostics = {},
            IncrementDiagnosticCounter = function(self, key)
                self.diagnostics[key] = (self.diagnostics[key] or 0) + 1
            end,
        })
        addon.GetCurrentSessionLootLocationData = function()
            attempts = attempts + 1
            if attempts == 1 then
                return { mapID = 100, coordinateSource = "unavailable" }
            end
            return {
                mapID = 100,
                mapName = "Hellfire Peninsula",
                mapX = 0.57,
                mapY = 0.23,
                coordinateSource = "live",
                coordinateCapturedAt = 1710000000,
            }
        end
        local entry = { mapID = 100 }

        loader.with_globals({
            C_Timer = {
                After = function(delay, callback)
                    queued[#queued + 1] = { delay = delay, callback = callback }
                end,
            },
        }, function()
            assert.is_true(addon:ScheduleLootCoordinateRecovery(entry, function(_, recovered)
                finished = recovered
            end))
            assert.equals("pending", entry.coordinateSource)
            assert.equals(0.1, queued[1].delay)

            queued[1].callback()
            assert.equals(0.5, queued[2].delay)
            queued[2].callback()
        end)

        assert.is_true(finished)
        assert.equals("retry", entry.coordinateSource)
        assert.equals(2, entry.coordinateRetryCount)
        assert.equals(0.57, entry.mapX)
        assert.equals(0.23, entry.mapY)
        assert.equals(1, addon.diagnostics.loot_coordinates_pending)
        assert.equals(1, addon.diagnostics.loot_coordinates_recovered)
    end)

    it("records market history immediately when loot is discovered", function()
        local discoveredItem
        local addon = load_valuation({
            db = {},
            session = {
                itemValue = 0,
                itemVendorValue = 0,
                itemLoots = {},
                highlightItemCount = 0,
            },
            BeginDiagnosticTimer = function()
                return 0
            end,
            EndDiagnosticTimer = function() end,
            IncrementDiagnosticCounter = function() end,
            GetSessionTotalValue = function()
                return 0
            end,
            GetItemUnitValue = function()
                return 5000, "TSM_DBMARKET", "Market Value"
            end,
            GetVendorItemValue = function()
                return 100
            end,
            GetLootItemMetadata = function()
                return { itemID = 12345 }
            end,
            GetItemQualityFromLink = function()
                return 2
            end,
            IsCraftingReagentItem = function()
                return false
            end,
            ShouldTrackItemForAH = function()
                return true
            end,
            IsSoulboundLootItem = function()
                return false
            end,
            IsLootSourceTrackingEnabled = function()
                return false
            end,
            GetHighlightThreshold = function()
                return 100000
            end,
            UpdateSessionLocationContext = function() end,
            GetCurrentSessionLootLocationData = function()
                return {}
            end,
            RecordDiscoveredItemMarketSnapshots = function(_, item)
                discoveredItem = item
            end,
            NotifyHighValueItem = function() end,
            UpdateMainWindow = function() end,
        })
        addon.GetItemUnitValue = function()
            return 5000, "TSM_DBMARKET", "Market Value"
        end
        addon.GetVendorItemValue = function()
            return 100
        end
        addon.GetLootItemMetadata = function()
            return { itemID = 12345 }
        end
        addon.GetCurrentSessionLootLocationData = function()
            return {}
        end

        loader.with_globals({
            time = function()
                return 1710000000
            end,
        }, function()
            addon:TrackLootItem("|cff1eff00|Hitem:12345::::::::|h[Test Green]|h|r", 2)
        end)

        assert.is_table(discoveredItem)
        assert.equals(12345, discoveredItem.itemID)
        assert.equals(2, discoveredItem.quantity)
        assert.equals(5000, discoveredItem.unitValue)
        assert.equals(10000, discoveredItem.totalValue)
        assert.equals("TSM_DBMARKET", discoveredItem.valueSourceID)
    end)
end)
