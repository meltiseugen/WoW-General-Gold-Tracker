local loader = require("tests.helpers.addon_loader")

local function load_service(addon, globals)
    return loader.with_globals(globals or {}, function()
        local _, ns = loader.load_module("Tracking/Loot/LootSourceService.lua", addon or {})
        return ns.LootSourceService:New(addon or {})
    end)
end

describe("Tracking/LootSourceService", function()
    it("normalizes source names and ignores secret values", function()
        local service = load_service({
            Trim = function(_, text)
                return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end,
        }, {
            issecretvalue = function(value)
                return value == "secret"
            end,
        })

        loader.with_globals({
            issecretvalue = function(value)
                return value == "secret"
            end,
        }, function()
            assert.equals("Test Mob", service:NormalizeDisplayedSourceName(" |cff00ff00Test Mob|r "))
            assert.is_nil(service:NormalizeDisplayedSourceName("secret"))
        end)
    end)

    it("resolves gather actions by spell ID and localized spell names", function()
        local service = load_service({}, {
            PROFESSIONS_MINING = "Minage",
            PROFESSIONS_HERBALISM = "Herboristerie",
            PROFESSIONS_SKINNING = "Depecage",
            PROFESSIONS_FISHING = "Peche",
            C_Spell = {
                GetSpellName = function(spell_id)
                    return spell_id == 999 and "Peche" or nil
                end,
            },
        })

        loader.with_globals({
            PROFESSIONS_MINING = "Minage",
            PROFESSIONS_HERBALISM = "Herboristerie",
            PROFESSIONS_SKINNING = "Depecage",
            PROFESSIONS_FISHING = "Peche",
            C_Spell = {
                GetSpellName = function(spell_id)
                    return spell_id == 999 and "Peche" or nil
                end,
            },
            GetSpellInfo = function()
                return nil
            end,
        }, function()
            assert.equals("Mining", service:GetGatherActionForSpell(2575))
            assert.equals("Fishing", service:GetGatherActionForSpell(999, "Peche"))
        end)
    end)

    it("formats source display text with pluralization and truncation", function()
        local service = load_service()

        assert.equals("Unit: Gnoll", service:BuildSourceDisplayText("Unit", { "Gnoll" }, 1))
        assert.equals(
            "Units (5): A, B, C +2",
            service:BuildSourceDisplayText("Unit", { "A", "B", "C", "D" }, 5)
        )
        assert.equals("Objects/Nodes (2)", service:BuildSourceDisplayText("Object/Node", {}, 2))
    end)

    it("remembers source names and expires stale cache entries", function()
        local now = 1000
        local service = load_service({}, {
            time = function()
                return now
            end,
        })

        loader.with_globals({
            time = function()
                return now
            end,
        }, function()
            service:RememberLootSourceName("Creature-0-1", "Rare Mob")
            assert.equals("Rare Mob", service:GetLootSourceNameFromGUID("Creature-0-1", false))
        end)

        now = 2001
        loader.with_globals({
            time = function()
                return now
            end,
        }, function()
            service:CleanupLootSourceNameCache()
        end)

        assert.is_nil(service.lootSourceNameCache["Creature-0-1"])
    end)

    it("builds mixed AOE loot source descriptors from weighted sources", function()
        local service = load_service()
        service.lootSourceNameCache = {
            ["Creature-1"] = { name = "Alpha", seenAt = 1 },
            ["Creature-2"] = { name = "Beta", seenAt = 1 },
            ["GameObject-1"] = { name = "Chest", seenAt = 1 },
        }

        local descriptor = service:BuildLootSourceInfoForSlot(1, {
            "Creature-1", 3,
            "Creature-2", 1,
            "GameObject-1", 3,
        })

        assert.equals("Mixed", descriptor.kind)
        assert.is_true(descriptor.isAoe)
        assert.matches("AOE Mixed", descriptor.text)
    end)
end)
