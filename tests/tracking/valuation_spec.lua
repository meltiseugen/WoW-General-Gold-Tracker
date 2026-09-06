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
end)
