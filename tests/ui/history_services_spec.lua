local loader = require("tests.helpers.addon_loader")

local function load_history_namespace(globals)
    return loader.with_globals(globals or {}, function()
        local addon = {
            Trim = function(_, text)
                if type(text) ~= "string" then
                    return ""
                end
                return text:gsub("^%s+", ""):gsub("%s+$", "")
            end,
            NormalizeValueSourceLabel = function(_, label)
                return label == "DBMarket" and "Market Value" or label
            end,
            GetConfiguredMinimumTrackedItemQuality = function()
                return 2
            end,
            GetItemQualityFromLink = function(_, item_link)
                return item_link == "quality-from-link" and 2 or nil
            end,
            IsLootSourceTrackingEnabled = function()
                return true
            end,
            SESSION_STYLE_ALL_ID = "all",
            NormalizeSessionStyleFilter = function(_, style_id)
                if style_id == "crafting" or style_id == "armorWeapons" or style_id == "other" then
                    return style_id
                end
                return "all"
            end,
            LootItemMatchesSessionStyle = function(_, entry, style_id)
                if style_id == "crafting" then
                    return entry and entry.isCraftingReagent == true
                end
                if style_id == "armorWeapons" then
                    return entry and (entry.itemClassID == 2 or entry.itemClassID == 4)
                end
                if style_id == "other" then
                    return entry
                        and entry.isCraftingReagent ~= true
                        and entry.itemClassID ~= 2
                        and entry.itemClassID ~= 4
                end
                return true
            end,
            COPPER_PER_GOLD = 10000,
            FormatMoney = function(_, value)
                return "money:" .. tostring(value)
            end,
        }
        local _, constants_ns = loader.load_module("UI/History/HistoryConstants.lua", addon)
        local constants = constants_ns.HistoryConstants
        local _, model_ns = loader.load_module("UI/History/HistorySessionModel.lua", addon, {
            HistoryConstants = constants,
        })
        local model = model_ns.HistorySessionModel
        local _, service_ns = loader.load_module("UI/History/HistoryDataService.lua", addon, {
            HistoryConstants = constants,
            HistorySessionModel = model,
        })
        local _, date_ns = loader.load_module("UI/History/HistoryDateFilter.lua", addon, {
            HistoryConstants = constants,
        })
        local _, formatter_ns = loader.load_module("UI/History/HistoryFormatter.lua", addon)
        return addon,
            constants,
            model,
            service_ns.HistoryDataService,
            date_ns.HistoryDateFilter,
            formatter_ns.HistoryFormatter
    end)
end

describe("UI/History date filtering and formatting", function()
    it("matches today, yesterday, last-seven-days, and this-month filters", function()
        local _, constants, _, _, DateFilter = load_history_namespace({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
            time = function(parts)
                return os.time(parts)
            end,
        })
        local now = os.time({ year = 2026, month = 8, day = 27, hour = 15, min = 0, sec = 0 })
        local filter = DateFilter:New(function()
            return now
        end)

        local today = os.time({ year = 2026, month = 8, day = 27, hour = 1, min = 0, sec = 0 })
        local yesterday = os.time({ year = 2026, month = 8, day = 26, hour = 23, min = 59, sec = 0 })
        local last_week = os.time({ year = 2026, month = 8, day = 21, hour = 0, min = 1, sec = 0 })
        local prior_month = os.time({ year = 2026, month = 7, day = 31, hour = 23, min = 0, sec = 0 })

        loader.with_globals({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
            time = function(parts)
                return os.time(parts)
            end,
        }, function()
            assert.is_true(filter:MatchesTimestamp(today, constants.DATE_FILTER_TODAY))
            assert.is_false(filter:MatchesTimestamp(yesterday, constants.DATE_FILTER_TODAY))
            assert.is_true(filter:MatchesTimestamp(yesterday, constants.DATE_FILTER_YESTERDAY))
            assert.is_true(filter:MatchesTimestamp(last_week, constants.DATE_FILTER_LAST_7_DAYS))
            assert.is_false(filter:MatchesTimestamp(prior_month, constants.DATE_FILTER_THIS_MONTH))
        end)
    end)

    it("truncates long session names while preserving date suffixes", function()
        local _, _, _, _, _, Formatter = load_history_namespace({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
        })
        local font = {
            width = 28,
            text = "",
            GetWidth = function(self)
                return self.width
            end,
            SetText = function(self, text)
                self.text = text
            end,
            GetStringWidth = function(self)
                return #self.text
            end,
        }
        local formatter = Formatter:New({})

        local result = formatter:TruncateSessionNameKeepingDate("Very Long Place Name - 2026-08-27 12:00", font)

        assert.matches("2026%-08%-27 12:00$", result)
        assert.matches("%.%.%.", result)
    end)
end)

describe("UI/History data service", function()
    it("aggregates visible detailed loot by item, value source, and loot source", function()
        local _, constants, _, DataService = load_history_namespace()
        local service = DataService:New({
            NormalizeValueSourceLabel = function(_, label)
                return label == "DBMarket" and "Market Value" or label
            end,
            GetConfiguredMinimumTrackedItemQuality = function()
                return 2
            end,
            IsLootSourceTrackingEnabled = function()
                return true
            end,
        }, constants.DETAILS_LOCATION_FILTER_ALL)
        local session = {
            valueSourceLabel = "Market Value",
            valueSourceLabels = { "Market Value", "Min Buyout" },
            itemLoots = {
                {
                    itemLink = "item-a",
                    quantity = 1,
                    totalValue = 100,
                    itemQuality = 2,
                    ahTracked = true,
                    valueSourceLabel = "Market Value",
                    lootSourceText = "Rare One",
                },
                {
                    itemLink = "item-a",
                    quantity = 2,
                    totalValue = 200,
                    itemQuality = 2,
                    ahTracked = true,
                    valueSourceLabel = "Market Value",
                    lootSourceText = "Rare One",
                },
                {
                    itemLink = "item-a",
                    quantity = 1,
                    totalValue = 500,
                    itemQuality = 2,
                    ahTracked = true,
                    valueSourceLabel = "Min Buyout",
                    lootSourceText = "Rare One",
                },
                {
                    itemLink = "low-quality",
                    quantity = 9,
                    totalValue = 900,
                    itemQuality = 1,
                    ahTracked = true,
                },
                {
                    itemLink = "soulbound",
                    quantity = 1,
                    totalValue = 999,
                    itemQuality = 4,
                    ahTracked = true,
                    isSoulbound = true,
                },
            },
        }

        local items, include_source_label =
            service:BuildVisibleHistoryItems(session, constants.DETAILS_LOCATION_FILTER_ALL)

        assert.is_true(include_source_label)
        assert.equals(2, #items)
        assert.equals("item-a", items[1].itemLink)
        assert.equals(500, items[1].totalValue)
        assert.equals("Min Buyout", items[1].valueSourceLabel)
        assert.equals(3, items[2].quantity)
        assert.equals(300, items[2].totalValue)
    end)

    it("summarizes selected-location money and item totals from detailed entries", function()
        local addon, constants, _, DataService = load_history_namespace({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
        })
        local service = DataService:New(addon, constants.DETAILS_LOCATION_FILTER_ALL)
        local session = {
            startTime = 100,
            stopTime = 500,
            zoneName = "Elwynn",
            mapID = 37,
            itemLoots = {
                { totalValue = 100, vendorTotalValue = 5, timestamp = 200, locationKey = "zone:Elwynn:37" },
                { totalValue = 999, timestamp = 300, locationKey = "zone:Durotar:1" },
            },
            moneyLoots = {
                { amount = 25, timestamp = 250, locationKey = "zone:Elwynn:37" },
            },
        }

        local summary = service:BuildHistoryDetailsSummary(session, "zone:Elwynn:37")

        assert.equals(25, summary.rawGold)
        assert.equals(100, summary.itemsValue)
        assert.equals(5, summary.itemsRawGold)
        assert.equals(125, summary.totalValue)
        assert.equals(50, summary.duration)
        assert.equals(200, summary.startTime)
        assert.equals(250, summary.stopTime)
    end)

    it("filters saved session summaries by the selected session style without counting raw gold", function()
        local addon, constants, _, DataService = load_history_namespace({
            date = function(format, timestamp)
                return os.date(format, timestamp)
            end,
        })
        local service = DataService:New(addon, constants.DETAILS_LOCATION_FILTER_ALL)
        local session = {
            startTime = 100,
            stopTime = 3700,
            rawGold = 999,
            itemLoots = {
                {
                    itemLink = "ore",
                    totalValue = 500,
                    vendorTotalValue = 20,
                    timestamp = 200,
                    itemClassID = 7,
                    isCraftingReagent = true,
                },
                {
                    itemLink = "sword",
                    totalValue = 1200,
                    vendorTotalValue = 50,
                    timestamp = 300,
                    itemClassID = 2,
                },
            },
            moneyLoots = {
                { amount = 999, timestamp = 150 },
            },
        }

        local all = service:BuildHistoryDetailsSummary(session, constants.DETAILS_LOCATION_FILTER_ALL, "all")
        local crafting = service:BuildHistoryDetailsSummary(session, constants.DETAILS_LOCATION_FILTER_ALL, "crafting")

        assert.equals(2699, all.totalValue)
        assert.equals(500, crafting.totalValue)
        assert.equals(0, crafting.rawGold)
        assert.equals(20, crafting.itemsRawGold)
        assert.equals(3600, crafting.duration)
        assert.equals(100, crafting.startTime)
    end)

    it("filters saved session item rows by session style", function()
        local addon, constants, _, DataService = load_history_namespace()
        local service = DataService:New(addon, constants.DETAILS_LOCATION_FILTER_ALL)
        local session = {
            valueSourceLabel = "Market Value",
            itemLoots = {
                {
                    itemLink = "ore",
                    quantity = 2,
                    totalValue = 500,
                    itemQuality = 2,
                    ahTracked = true,
                    itemClassID = 7,
                    isCraftingReagent = true,
                },
                {
                    itemLink = "sword",
                    quantity = 1,
                    totalValue = 1200,
                    itemQuality = 3,
                    ahTracked = true,
                    itemClassID = 2,
                },
                {
                    itemLink = "pet",
                    quantity = 1,
                    totalValue = 200,
                    itemQuality = 2,
                    ahTracked = true,
                    itemClassID = 15,
                },
            },
        }

        local crafting = service:BuildVisibleHistoryItems(session, constants.DETAILS_LOCATION_FILTER_ALL, "crafting")
        local armor = service:BuildVisibleHistoryItems(session, constants.DETAILS_LOCATION_FILTER_ALL, "armorWeapons")
        local other = service:BuildVisibleHistoryItems(session, constants.DETAILS_LOCATION_FILTER_ALL, "other")

        assert.equals(1, #crafting)
        assert.equals("ore", crafting[1].itemLink)
        assert.equals(1, #armor)
        assert.equals("sword", armor[1].itemLink)
        assert.equals(1, #other)
        assert.equals("pet", other[1].itemLink)
    end)
end)
