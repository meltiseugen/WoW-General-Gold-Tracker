local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local LINEN_WOOL_GUIDE = "https://www.wowhead.com/guide/classic-cloth-farming-linen-wool"
local SILK_PLUS_GUIDE = "https://www.wowhead.com/guide/classic-cloth-farming-silk-mageweave-runecloth-felcloth"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTES = {
    linen = {
        urls = { LINEN_WOOL_GUIDE, "https://www.wow-professions.com/farming/linen-cloth-farming", ItemUrl(2589), "https://www.wowhead.com/npc=504/defias-trapper" },
        mapName = "Westfall",
        location = "Defias and Riverpaw camps around Jangolode Mine, Furlbrow's Pumpkin Farm, and Moonbrook",
        density = "High",
        difficulty = "Easy. Linen is fastest from dense level 10-17 humanoid camps.",
        tips = {
            "Use Westfall for Alliance-friendly Linen density with compact Defias camps.",
            "Clear camps in a loop instead of waiting at one farm.",
            "Humanoid camps also produce coin, greens, and early cooking/cloth side value.",
        },
        coords = {
            C(0.444, 0.200, "Jangolode Mine Defias"),
            C(0.558, 0.310, "Furlbrow's Pumpkin Farm Defias"),
            C(0.426, 0.612, "Moonbrook northwest Defias"),
            C(0.452, 0.704, "Moonbrook south Defias"),
            C(0.362, 0.780, "Dagger Hills Defias"),
        },
    },
    wool = {
        urls = { LINEN_WOOL_GUIDE, "https://www.wow-professions.com/farming/wool-cloth-farming", ItemUrl(2592), "https://www.wowhead.com/npc=3780/shadethicket-moss-eater" },
        mapName = "Ashenvale",
        location = "Thistlefur, Foulweald, Dark Strand, and Night Run humanoid/satyr route",
        density = "Medium",
        difficulty = "Moderate. Wool drops slower than Linen and is best from level 16-26 humanoids.",
        tips = {
            "Ashenvale has several independent Wool camps, making it resilient to competition.",
            "Avoid mobs that are too low because Linen/Wool overlap lowers yield.",
            "Satyr camps can add early demonic cloth and green value.",
        },
        coords = {
            C(0.344, 0.320, "Thistlefur camp"),
            C(0.446, 0.544, "Foulweald Den edge"),
            C(0.642, 0.398, "Night Run satyrs"),
            C(0.176, 0.206, "Dark Strand naga/humanoids"),
            C(0.562, 0.632, "Satyrnaar route"),
        },
    },
    silk = {
        urls = { SILK_PLUS_GUIDE, "https://www.wow-professions.com/farming/silk-cloth-farming", ItemUrl(4306), "https://www.wowhead.com/zone=796/scarlet-monastery" },
        mapName = "Tirisfal Glades",
        location = "Scarlet Monastery entrance and repeatable Scarlet humanoid clears",
        density = "High in dungeon clears",
        difficulty = "Good. Scarlet Monastery is repeatable and avoids outdoor competition.",
        tips = {
            "Use Scarlet Monastery clears when your character can reset quickly.",
            "Outdoor Arathi or Thousand Needles camps are backups, but SM is easier to model.",
            "Sell or disenchant green drops depending on market values.",
        },
        coords = {
            C(0.846, 0.322, "Scarlet Monastery entrance"),
            C(0.818, 0.346, "Scarlet Monastery outer road"),
            C(0.798, 0.304, "Scarlet Monastery approach"),
        },
    },
    mageweave = {
        urls = { SILK_PLUS_GUIDE, "https://www.wow-professions.com/farming/mageweave-cloth-farming", ItemUrl(4338), "https://www.wowhead.com/zone=978/zulfarrak" },
        mapName = "Tanaris",
        location = "Dunemaul ogres, Wastewander camps, and Zul'Farrak entrance/clear route",
        density = "High",
        difficulty = "Good. Tanaris ogres and Zul'Farrak clears are classic Mageweave volume farms.",
        tips = {
            "Dunemaul ogres have compact camps and quick travel between pulls.",
            "Zul'Farrak is strong if your character can clear many humanoids quickly.",
            "Tanaris also supports Mithril and high-mid herb side routes.",
        },
        coords = {
            C(0.398, 0.552, "Gadgetzan south Wastewander"),
            C(0.410, 0.722, "Dunemaul Compound west"),
            C(0.472, 0.742, "Dunemaul Compound east"),
            C(0.394, 0.214, "Zul'Farrak entrance"),
            C(0.656, 0.316, "Lost Rigger Cove humanoids"),
        },
    },
    runecloth = {
        urls = { SILK_PLUS_GUIDE, "https://www.wow-professions.com/farming/runecloth-farming", ItemUrl(14047), "https://www.wowhead.com/zone=2017/stratholme" },
        mapName = "Eastern Plaguelands",
        location = "Tyr's Hand, Corin's Crossing, Plaguewood, and Stratholme entrance route",
        density = "High",
        difficulty = "Moderate. Best targets are level 55-60 humanoid, undead, and demon camps.",
        tips = {
            "Use Tyr's Hand and Plaguelands undead for open-world Runecloth.",
            "Use Stratholme if you want repeatable undead density.",
            "Equip Argent Dawn reputation tools in Classic contexts when farming undead.",
        },
        coords = {
            C(0.760, 0.744, "Tyr's Hand Scarlet camps"),
            C(0.564, 0.660, "Lake Mereldar undead"),
            C(0.344, 0.456, "Corin's Crossing undead"),
            C(0.272, 0.116, "Stratholme service entrance"),
            C(0.220, 0.248, "Plaguewood undead"),
        },
    },
    felcloth = {
        urls = { SILK_PLUS_GUIDE, "https://www.wow-professions.com/farming/felcloth-farming", ItemUrl(14256), "https://www.wowhead.com/npc=7106/jadefire-rogue" },
        mapName = "Felwood",
        location = "Jadefire satyr/demon route through Jadefire Glen and Jadefire Run",
        density = "Low drop rate, medium mob density",
        difficulty = "Harder than normal cloth. Felcloth is a rare demon cloth, so volume and reset routing matter.",
        tips = {
            "Farm demons and satyrs, not generic humanoids.",
            "Treat Runecloth as steady income and Felcloth as the premium drop.",
            "Pair with Gromsblood, Dreamfoil, and Golden Sansam herb checks.",
        },
        coords = {
            C(0.398, 0.186, "Jadefire Glen northwest"),
            C(0.414, 0.224, "Jadefire Glen center"),
            C(0.440, 0.266, "Jadefire Glen southeast"),
            C(0.388, 0.520, "Jaedenar demon route"),
            C(0.486, 0.742, "Jadefire Run"),
        },
    },
}

local function RegisterCloth(itemID, itemName, category, routeKey, summary)
    local route = ROUTES[routeKey]
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "tailoring" },
        category = category,
        researchStatus = "researched",
        sourceUrls = route.urls,
        summary = summary,
        spots = {
            {
                id = "classic-cloth-" .. routeKey .. "-" .. tostring(itemID),
                source = "Wowhead retail cloth guides, wow-professions farming guides, Wowhead NPC/zone pages, and cloth comments",
                sourceUrls = route.urls,
                mapName = route.mapName,
                location = route.location,
                routeType = "humanoid-cloth-farm",
                density = route.density,
                dropDifficulty = route.difficulty,
                tips = route.tips,
                coords = route.coords,
                confidence = "high",
            },
        },
    })
end

RegisterCloth(2589, "Linen Cloth", "Cloth", "linen", "Starter cloth from dense low-level humanoid camps.")
RegisterCloth(2592, "Wool Cloth", "Cloth", "wool", "Low-mid cloth from level 16-26 humanoids.")
RegisterCloth(4306, "Silk Cloth", "Cloth", "silk", "Mid-level cloth from Scarlet Monastery and outdoor humanoid camps.")
RegisterCloth(4338, "Mageweave Cloth", "Cloth", "mageweave", "High-mid cloth from Tanaris, Feralas, and Zul'Farrak routes.")
RegisterCloth(14047, "Runecloth", "Cloth", "runecloth", "Endgame cloth from Plaguelands, Felwood, Silithus, and dungeon-style humanoid/undead farms.")
RegisterCloth(14256, "Felcloth", "Cloth", "felcloth", "Rare demon cloth from satyr and demon farms, often paired with Runecloth farming.")
