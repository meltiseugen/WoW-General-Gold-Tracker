local loader = require("tests.helpers.addon_loader")

local function load_flow(addon)
    return loader.load_module("Core/SessionFlow.lua", addon or {})
end

describe("Core/SessionFlow location transition policy", function()
    it("does not transition inactive, missing, or unchanged locations", function()
        local addon = load_flow()

        assert.is_nil(addon:GetSessionLocationTransitionDecision({ active = false }, { locationKey = "zone:2" }, true))
        assert.is_nil(addon:GetSessionLocationTransitionDecision({ active = true }, { locationKey = "zone:2" }, true))
        assert.is_nil(addon:GetSessionLocationTransitionDecision(
            { active = true, locationKey = "zone:1" },
            { locationKey = "zone:1" },
            true
        ))
    end)

    it("blocks non-instance zone transitions unless the option is enabled", function()
        local addon = load_flow()

        assert.is_nil(addon:GetSessionLocationTransitionDecision(
            { active = true, locationKey = "zone:1", zoneName = "Old Zone" },
            { locationKey = "zone:2", zoneName = "New Zone", isInstanced = false },
            false
        ))
    end)

    it("builds zone transition metadata when zone auto-start is enabled", function()
        local addon = load_flow()

        local decision = addon:GetSessionLocationTransitionDecision(
            { active = true, locationKey = "zone:1", zoneName = "Old Zone" },
            { locationKey = "zone:2", zoneName = "New Zone", isInstanced = false },
            true
        )

        assert.equals("zone", decision.transitionLabel)
        assert.equals("location-switch", decision.saveReason)
        assert.equals("Old Zone", decision.previousName)
        assert.equals("New Zone", decision.currentName)
    end)

    it("builds instance transition metadata for entering or leaving an instance", function()
        local addon = load_flow()

        local entering = addon:GetSessionLocationTransitionDecision(
            { active = true, locationKey = "zone:1", zoneName = "Old Zone", isInstanced = false },
            { locationKey = "instance:2", instanceName = "Dungeon", isInstanced = true },
            false
        )
        local leaving = addon:GetSessionLocationTransitionDecision(
            { active = true, locationKey = "instance:2", instanceName = "Dungeon", isInstanced = true },
            { locationKey = "zone:3", zoneName = "Outside", isInstanced = false },
            true
        )

        assert.equals("instance", entering.transitionLabel)
        assert.equals("instance-switch", entering.saveReason)
        assert.equals("Dungeon", entering.currentName)
        assert.equals("instance", leaving.transitionLabel)
        assert.equals("instance-switch", leaving.saveReason)
        assert.equals("Dungeon", leaving.previousName)
    end)
end)
