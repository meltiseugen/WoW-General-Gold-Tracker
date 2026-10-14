local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BOREAN_LEATHER_ROUTE = {
    id = "wrath-borean-leather-zuldrak-fast-spawn-skinning",
    source = "Wowhead Borean Leather forum reports and Wowhead rare leather guide",
    sourceUrls = {
        "https://www.wowhead.com/forums/topic/borean-leather-farming-59420",
        "https://www.wowhead.com/guide/leather-best-farming-locations",
        ItemUrl(33568),
    },
    mapName = "Zul'Drak",
    location = "Troll Patrol alchemy area with fast-spawning bats and spiders",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Easy if the area is active. Other players may leave skinnable corpses, but competition varies.",
    tips = {
        "Circle the troll patrol alchemy camp and skin bats and spiders as they are killed.",
        "This is a broad Borean Leather route, so value depends on how quickly corpses appear.",
        "Use a secondary route if quest traffic is low.",
    },
    coords = {
        C(0.334, 0.742, "Alchemy camp west edge"),
        C(0.366, 0.716, "Central fast-spawn camp"),
        C(0.402, 0.738, "East camp checks"),
        C(0.382, 0.782, "South camp return"),
    },
    confidence = "medium",
}

local ARCTIC_FUR_ROUTE = {
    id = "wrath-arctic-fur-storm-peaks-grims-cave",
    source = "Wowhead Arctic Fur comments and Wowhead rare leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=44128/arctic-fur",
        "https://www.wowhead.com/guide/leather-best-farming-locations",
    },
    mapName = "The Storm Peaks",
    location = "Cave east of the Engine of the Makers with dense worg and worm skins",
    routeType = "rare-side-skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Rare side material from eligible Northrend skins; farm for leather and treat Arctic Fur as bonus value.",
    tips = {
        "Clear the cave and nearby packs repeatedly rather than chasing individual rare-fur sources.",
        "Expect Arctic Fur to be streaky because it is a rare skinning result.",
        "This route also creates Borean Leather and Jormungar Scale side value.",
    },
    coords = {
        C(0.544, 0.626, "Cave mouth"),
        C(0.560, 0.648, "Inner cave loop"),
        C(0.580, 0.662, "Deep cave loop"),
        C(0.602, 0.640, "Outer cave return"),
    },
    confidence = "medium",
}

local ICY_DRAGONSCALE_ROUTE = {
    id = "wrath-icy-dragonscale-sholazar-drake-skinning",
    source = "Wowhead Icy Dragonscale comments and Wowhead rare leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=38557/icy-dragonscale",
        "https://www.wowhead.com/guide/leather-best-farming-locations",
    },
    mapName = "Sholazar Basin",
    location = "North Sholazar drake and whelp skinning pockets",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Moderate. It requires skinning dragonkin; not a normal loot drop.",
    tips = {
        "Skin eligible drakes and whelps; the item does not drop directly into loot for non-skinners.",
        "Dungeon farms such as The Oculus and Violet Hold are stronger when you can chain-reset them.",
        "Use Sholazar when you want an open-world route instead of dungeon resets.",
    },
    coords = {
        C(0.360, 0.296, "Northwest drake pocket"),
        C(0.386, 0.254, "Northern drake pocket"),
        C(0.420, 0.284, "Central drake pocket"),
        C(0.446, 0.320, "Eastern drake pocket"),
    },
    confidence = "medium",
}

local NERUBIAN_CHITIN_ROUTE = {
    id = "wrath-nerubian-chitin-dragonblight-icemist-village",
    source = "Wowhead Nerubian Chitin comments and Wowhead rare leather guide",
    sourceUrls = {
        "https://www.wowhead.com/item=38558/nerubian-chitin",
        "https://www.wowhead.com/guide/leather-best-farming-locations",
    },
    mapName = "Dragonblight",
    location = "Icemist Village and nearby nerubian packs east of Westwind Refugee Camp",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Good targeted open-world chitin route with dense nerubian pulls.",
    tips = {
        "Focus Anub'ar Ambushers and Dreadweavers around Icemist Village.",
        "Instance routes in Azjol-Nerub and Ahn'kahet can be stronger if you want a controlled reset loop.",
        "Skin everything before moving deeper so the camp keeps cycling.",
    },
    coords = {
        C(0.250, 0.436, "West Icemist packs"),
        C(0.272, 0.456, "Central Icemist packs"),
        C(0.300, 0.420, "North Icemist packs"),
        C(0.326, 0.468, "East Icemist packs"),
    },
    confidence = "high",
}

local JORMUNGAR_SCALE_ROUTE = {
    id = "wrath-jormungar-scale-storm-peaks-snowdrift-jormungar",
    source = "Wowhead Jormungar Scale and Snowdrift Jormungar pages",
    sourceUrls = {
        "https://www.wowhead.com/item=38561/jormungar-scale",
        "https://www.wowhead.com/npc=29390/snowdrift-jormungar",
    },
    mapName = "The Storm Peaks",
    location = "Snowdrift Jormungar and nearby worm pockets",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Worm skins are localized, so keep the loop tight.",
    tips = {
        "Target worm packs rather than broad beast routes when Jormungar Scale is the value source.",
        "Combine this with Arctic Fur/Borean Leather checks if the cave route is active.",
    },
    coords = {
        C(0.460, 0.530, "Western worm pocket"),
        C(0.480, 0.548, "Central worm pocket"),
        C(0.500, 0.562, "Southern worm pocket"),
        C(0.516, 0.534, "Eastern worm pocket"),
        C(0.544, 0.626, "Cave-side worm checks"),
    },
    confidence = "medium",
}

local function RegisterSkinning(itemID, itemName, category, spots, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "skinning", "leatherworking" },
        category = category,
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/guide/leather-best-farming-locations" },
        summary = summary,
        spots = spots,
    })
end

RegisterSkinning(33568, "Borean Leather", "Leather", { BOREAN_LEATHER_ROUTE, ARCTIC_FUR_ROUTE }, "Baseline Northrend leather from dense skinnable beast routes.")
RegisterSkinning(44128, "Arctic Fur", "Leather", { ARCTIC_FUR_ROUTE }, "Rare Northrend skinning result from eligible Northrend skins.")
RegisterSkinning(38557, "Icy Dragonscale", "Scale", { ICY_DRAGONSCALE_ROUTE }, "Northrend dragonkin skinning material from dragon-heavy routes and dungeons.")
RegisterSkinning(38558, "Nerubian Chitin", "Chitin", { NERUBIAN_CHITIN_ROUTE }, "Northrend chitin from nerubian skinning routes and nerubian-heavy dungeons.")
RegisterSkinning(38561, "Jormungar Scale", "Scale", { JORMUNGAR_SCALE_ROUTE }, "Northrend worm scale from jormungar skinning routes.")
