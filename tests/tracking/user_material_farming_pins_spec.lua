local loader = require("tests.helpers.addon_loader")

local ITEM_LINK = "|cffffffff|Hitem:222::::::::|h[Primal Scale]|h|r"

local function load_user_pins(addon, ns_overrides)
    addon = addon or {}
    addon.db = addon.db or {
        userMaterialFarmingPins = {},
    }
    addon.GetItemIDFromLink = addon.GetItemIDFromLink or function(_, item_link)
        return tonumber(string.match(item_link or "", "item:(%d+)"))
    end

    return loader.load_module("Tracking/UserMaterialFarmingPins.lua", addon, ns_overrides)
end

local function count_table_entries(values)
    local count = 0
    for _ in pairs(values or {}) do
        count = count + 1
    end
    return count
end

describe("Tracking/UserMaterialFarmingPins", function()
    it("records user-discovered material pins separately from addon seed data", function()
        local now = 1710000000
        local addon = load_user_pins(nil, {
            FarmingItems = {
                items = {},
            },
        })

        loader.with_globals({
            time = function()
                return now
            end,
        }, function()
            assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
                ITEM_LINK,
                1,
                { itemID = 222 },
                true,
                { kind = "Skinning", name = "River Beast", text = "Skinning: River Beast" },
                { mapID = 37, mapName = "Elwynn Forest", mapX = 0.421, mapY = 0.511 }
            ))
            now = now + 3
            assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
                ITEM_LINK,
                2,
                { itemID = 222 },
                true,
                { kind = "Skinning", name = "River Beast", text = "Skinning: River Beast" },
                { mapID = 37, mapName = "Elwynn Forest", mapX = 0.422, mapY = 0.512 }
            ))
        end)

        local itemEntry = addon.db.userMaterialFarmingPins.items["222"]
        assert.is_table(itemEntry)
        assert.equals(2, itemEntry.seenCount)
        assert.equals(3, itemEntry.totalQuantity)
        assert.is_nil(addon.db.userMaterialFarmingPins.static)

        local mapEntry = itemEntry.maps["37"]
        assert.is_table(mapEntry)
        assert.equals(1, count_table_entries(mapEntry.pins))

        local options = addon:BuildUserMaterialFarmingMapOptions(222, "Fallback Scale")
        assert.equals(1, #options)
        assert.equals("Elwynn Forest (User)", options[1].label)
        assert.equals("user", options[1].sourceType)
        assert.equals("User discoveries", options[1].pins[1].sourceLabel)
        assert.equals("2 seen, 3 looted", options[1].pins[1].density)
    end)

    it("records gathering, object-node, and unknown-source loot but ignores instances", function()
        local addon = load_user_pins()

        loader.with_globals({
            time = function()
                return 1710000000
            end,
        }, function()
            for _, kind in ipairs({ "Mining", "Herbalism", "Object/Node" }) do
                assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
                    ITEM_LINK,
                    1,
                    { itemID = 222 },
                    true,
                    { kind = kind },
                    { mapID = 37, mapName = "Elwynn Forest", mapX = 0.42, mapY = 0.51 }
                ))
            end
            assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
                ITEM_LINK,
                1,
                { itemID = 222 },
                true,
                nil,
                { mapID = 37, mapName = "Elwynn Forest", mapX = 0.42, mapY = 0.51 }
            ))
            assert.is_false(addon:RecordUserMaterialFarmingPinForLoot(
                ITEM_LINK,
                1,
                { itemID = 222 },
                true,
                { kind = "Skinning" },
                { isInstanced = true, mapID = 37, mapName = "Elwynn Forest", mapX = 0.42, mapY = 0.51 }
            ))
        end)

        local itemEntry = addon:GetUserMaterialFarmingPinStore().items["222"]
        assert.is_table(itemEntry)
        assert.equals(4, itemEntry.seenCount)
        assert.equals(1, count_table_entries(itemEntry.maps["37"].pins))
    end)

    it("records known material items even when the client does not flag them as crafting reagents", function()
        local addon = load_user_pins(nil, {
            FarmingItems = {
                items = {
                    { itemID = 222, expansion = "classic", professions = { "skinning" } },
                },
            },
        })

        loader.with_globals({
            time = function()
                return 1710000000
            end,
        }, function()
            assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
                ITEM_LINK,
                1,
                { itemID = 222 },
                false,
                { kind = "Unit", name = "Air Elemental", text = "Unit: Air Elemental" },
                { mapID = 37, mapName = "Elwynn Forest", mapX = 42, mapY = 51 }
            ))
        end)

        assert.is_table(addon.db.userMaterialFarmingPins.items["222"])
    end)

    it("reports missing-coordinate and recorded-pin diagnostics", function()
        local addon = load_user_pins({
            db = { userMaterialFarmingPins = {} },
            diagnostics = {},
            IncrementDiagnosticCounter = function(self, key)
                self.diagnostics[key] = (self.diagnostics[key] or 0) + 1
            end,
        }, {
            FarmingItems = {
                items = {
                    { itemID = 222 },
                },
            },
        })

        assert.is_false(addon:RecordUserMaterialFarmingPinForLoot(
            ITEM_LINK,
            1,
            { itemID = 222 },
            true,
            { kind = "Unit", name = "Fire Elemental" },
            { mapID = 100, mapName = "Hellfire Peninsula" }
        ))
        assert.equals(1, addon.diagnostics.material_pin_missing_coordinates)

        assert.is_true(addon:RecordUserMaterialFarmingPinForLoot(
            ITEM_LINK,
            1,
            { itemID = 222 },
            true,
            { kind = "Unit", name = "Fire Elemental" },
            { mapID = 100, mapName = "Hellfire Peninsula", mapX = 0.57, mapY = 0.23 }
        ))
        assert.equals(1, addon.diagnostics.material_pin_recorded)
    end)
end)
