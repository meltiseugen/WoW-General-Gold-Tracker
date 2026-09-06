local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local NIGHTFALL_SANCTUM_TINDERBOX_ROUTE = {
    id = "tww-reagent-nightfall-sanctum-profaned-tinderbox-route",
    source = "Wowhead Profaned Tinderbox comments, delve container hotfix notes, and Method Profaned Tinderbox guide",
    sourceUrls = {
        "https://www.wowhead.com/item=221758/profaned-tinderbox",
        "https://www.method.gg/guides/how-to-farm-profaned-tinderbox-in-the-war-within",
    },
    mapName = "Nightfall Sanctum",
    location = "Delve chest and Heavy Trunk checks",
    routeType = "delve-container-farm",
    density = "Container-limited",
    dropDifficulty = "Moderate. Community comments point to Nightfall Sanctum chest checks, and later hotfix "
        .. "notes moved delve reagents into Heavy Trunks across delves.",
    tips = {
        "Run low tiers quickly when the goal is repeated container checks rather than gear progression.",
        "Check Brann gathering rewards and end chests before resetting or moving to another delve.",
        "Method gives /way 39.12 74.33 for a Sturdy Chest check tied to this farm.",
    },
    coords = {
        C(0.3912, 0.7433, "Nightfall Sanctum Sturdy Chest check"),
    },
    confidence = "medium",
}

local DORNOGAL_TINDERBOX_EXCHANGE = {
    id = "tww-reagent-dornogal-profaned-tinderbox-borgos-exchange",
    source = "Wowhead Profaned Tinderbox comments and item vendor data",
    sourceUrls = {
        "https://www.wowhead.com/item=221758/profaned-tinderbox",
    },
    mapName = "Dornogal",
    location = "Borgos blacksmithing supplies exchange",
    routeType = "vendor-exchange",
    density = "Vendor-limited",
    dropDifficulty = "Exchange route rather than a drop farm; use when spare delve/vendor reagents are cheaper "
        .. "than farming a tinderbox directly.",
    tips = {
        "A Wowhead comment places Borgos at 48.8, 62.6 in Dornogal.",
        "Compare the cost of exchange inputs against the current Profaned Tinderbox price before buying.",
    },
    coords = {
        C(0.488, 0.626, "Borgos vendor exchange"),
    },
    confidence = "medium",
}

local ECHOING_FLUX_VENDOR_SPOTS = {
    {
        id = "tww-reagent-dornogal-echoing-flux-vendors",
        source = "Wowhead Echoing Flux item page and vendor comments",
        sourceUrls = {
            "https://www.wowhead.com/item=226202/echoing-flux",
        },
        mapName = "Dornogal",
        location = "Blacksmithing supply vendors",
        routeType = "vendor-purchase",
        density = "Vendor",
        dropDifficulty = "Direct vendor material. It is not a mob or node farm.",
        tips = {
            "Wowhead lists Echoing Flux as sold by blacksmithing vendors.",
            "Borgos is also called out in Profaned Tinderbox exchange comments at 48.8, 62.6.",
        },
        coords = {
            C(0.488, 0.626, "Borgos blacksmithing supplies"),
        },
        confidence = "high",
    },
    {
        id = "tww-reagent-isle-of-dorn-rambleshire-echoing-flux-vendor",
        source = "Wowhead Echoing Flux comments",
        sourceUrls = {
            "https://www.wowhead.com/item=226202/echoing-flux",
        },
        mapName = "Isle of Dorn",
        location = "Rambleshire blacksmithing supplies",
        routeType = "vendor-purchase",
        density = "Vendor",
        dropDifficulty = "Direct vendor purchase from a reported blacksmithing supply NPC.",
        tips = {
            "A Wowhead comment reports QM Ironstead Guldsh in Rambleshire at 58,28.",
            "Use this if you are already farming Rambleshire skinning or Isle of Dorn ore routes.",
        },
        coords = {
            C(0.580, 0.280, "QM Ironstead Guldsh"),
        },
        confidence = "medium",
    },
}

Register({
    itemID = 221758,
    itemName = "Profaned Tinderbox",
    expansion = "warWithin",
    professions = { "blacksmithing", "enchanting" },
    category = "Reagent",
    sourceUrls = { ItemUrl(221758) },
    summary = "War Within delve/vendor reagent. Use Nightfall Sanctum container checks or the Dornogal vendor "
        .. "exchange when inputs are favorable.",
    spots = {
        NIGHTFALL_SANCTUM_TINDERBOX_ROUTE,
        DORNOGAL_TINDERBOX_EXCHANGE,
    },
})

Register({
    itemID = 226202,
    itemName = "Echoing Flux",
    expansion = "warWithin",
    professions = { "vendor", "blacksmithing" },
    category = "Flux",
    sourceUrls = { ItemUrl(226202) },
    summary = "War Within blacksmithing flux sold by vendors; stored as vendor-purchase spots with exact coordinates.",
    spots = ECHOING_FLUX_VENDOR_SPOTS,
})
