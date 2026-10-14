local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local FREEHOLD_CLOTH_ROUTE = {
    id = "bfa-freehold-tidespray-linen-route",
    source = "wow-professions Tidespray Linen guide, Artisans route notes, and Reddit cloth farm reports",
    sourceUrls = {
        "https://www.wow-professions.com/farming/tidespray-linen-farming",
        "https://artisansofazeroth.com/tidespray-linen-farming/",
        "https://www.reddit.com/r/woweconomy/comments/as1blm/how_is_tidespray_linen_and_deep_sea_satin_so/",
    },
    mapName = "Tiragarde Sound",
    location = "Outdoor Freehold humanoid loop",
    routeType = "humanoid-cloth-loop",
    density = "High",
    dropDifficulty = "Good solo loop, much stronger in 2x4 groups. Deep Sea Satin is much rarer.",
    tips = {
        "Farm the non-instance outdoor Freehold area, not the dungeon.",
        "Pull compact pirate packs and make a wider loop if respawns lag behind.",
        "Tailoring skill dramatically improves BFA cloth farming returns.",
    },
    coords = {
        C(0.742, 0.806, "Northern Freehold packs"),
        C(0.784, 0.836, "Central Freehold packs"),
        C(0.816, 0.786, "Eastern pirate packs"),
        C(0.766, 0.742, "Bridge and lower yard"),
        C(0.704, 0.780, "Western return"),
    },
    confidence = "high",
}

local STORMSONG_CLOTH_ROUTE = {
    id = "bfa-stormsong-jeweled-coast-cloth-route",
    source = "wow-professions Deep Sea Satin guide and Reddit Jeweled Coast reports",
    sourceUrls = {
        "https://www.wow-professions.com/farming/deep-sea-satin-farming",
        "https://www.reddit.com/r/woweconomy/comments/as1blm/how_is_tidespray_linen_and_deep_sea_satin_so/",
    },
    mapName = "Stormsong Valley",
    location = "Jeweled Coast humanoid cloth farm",
    routeType = "humanoid-cloth-loop",
    density = "Medium",
    dropDifficulty = "Deep Sea Satin is low rate; best used as side value while farming Tidespray Linen.",
    tips = {
        "Use this as a quieter backup to Freehold.",
        "Expect Tidespray Linen volume to be much higher than Deep Sea Satin.",
        "Group farming improves cloth yield dramatically.",
    },
    coords = {
        C(0.618, 0.622, "Jeweled Coast north"),
        C(0.668, 0.658, "Jeweled Coast center"),
        C(0.704, 0.604, "Eastern coast packs"),
        C(0.642, 0.552, "Northern return"),
        C(0.574, 0.584, "Western coast packs"),
    },
    confidence = "medium",
}

local function RegisterCloth(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "battleForAzeroth",
        professions = { "tailoring" },
        category = "Cloth",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = {
            FREEHOLD_CLOTH_ROUTE,
            STORMSONG_CLOTH_ROUTE,
        },
    })
end

RegisterCloth(152576, "Tidespray Linen", "Common BFA cloth from humanoids, best in outdoor Freehold loops.")
RegisterCloth(152577, "Deep Sea Satin", "Rare BFA cloth from the same mobs that drop Tidespray Linen.")
