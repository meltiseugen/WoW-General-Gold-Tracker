local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local LUREDROP_SPOTS = {
    {
        id = "tww-luredrop-ringing-deeps-dark-route",
        source = "Wowhead Luredrop comments, herbalism overview, and Luredrop object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210799/luredrop",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "The Ringing Deeps",
        location = "Northern dark tunnel route where Luredrop object pins overlap Mycobloom and Orbinid checks",
        routeType = "terrain-targeted-herb-loop",
        density = "Medium",
        dropDifficulty = "Moderate to hard because Luredrop favors hidden, dark, cave, and rare-spawn-adjacent spaces.",
        tips = {
            "Prioritize low-light cave pockets over bright surface loops.",
            "Gather nearby herbs because Luredrop can share respawn space with common nodes.",
            "Use Phial of Truesight while checking underground side paths.",
        },
        coords = {
            C(0.341, 0.157, "Northern Luredrop pocket"),
            C(0.346, 0.174, "North tunnel Luredrop check"),
            C(0.350, 0.131, "Dark tunnel north edge"),
            C(0.351, 0.188, "Luredrop and Mycobloom wall"),
            C(0.351, 0.208, "South bend Luredrop pin"),
            C(0.355, 0.147, "Northern return check"),
        },
        confidence = "high",
    },
    {
        id = "tww-luredrop-hallowfall-beledars-bounty-route",
        source = "Wowhead Luredrop object map pins and herbalism overview",
        sourceUrls = {
            "https://www.wowhead.com/item=210799/luredrop",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Beledar's Bounty farm pockets and nearby shaded herb checks",
        routeType = "localized-herb-check",
        density = "Localized",
        dropDifficulty = "Useful secondary Luredrop spot when Hallowfall herb prices are favorable.",
        tips = {
            "Work this into the Rich Soil route rather than flying only for Luredrop.",
            "Check farm edges and shaded pockets, then continue if no Luredrop is up.",
        },
        coords = {
            C(0.464, 0.647, "West farm Luredrop pin"),
            C(0.465, 0.649, "Farm edge Luredrop"),
            C(0.477, 0.634, "Central farm Luredrop check"),
            C(0.478, 0.645, "Southeast farm Luredrop"),
            C(0.480, 0.621, "North farm Luredrop check"),
        },
        confidence = "medium",
    },
}

local ORBINID_SPOTS = {
    {
        id = "orbinid-isle-of-dorn-freywold-cave",
        source = "Wowhead item comments and Orbinid object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
        },
        mapName = "Isle of Dorn",
        location = "Mushroom cave southeast/southwest of Freywold Village",
        routeType = "cave-check",
        density = "Localized",
        dropDifficulty = "Moderate. Reported as a good specific cave check after surface routes produced little.",
        tips = {
            "Fly over or into caves to inspect node spawns quickly.",
            "A reported cave entrance is around 33.56, 80.05.",
            "Use Phial of Truesight while checking nearby camouflaged herbs.",
        },
        coords = {
            C(0.3356, 0.8005, "Reported Freywold cave entrance"),
            C(0.338, 0.794, "Nearby Orbinid object pin"),
            C(0.340, 0.797, "Freywold cave return"),
        },
        confidence = "medium",
    },
    {
        id = "orbinid-isle-of-dorn-three-shields-caves",
        source = "Wowhead item comments and Orbinid object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
        },
        mapName = "Isle of Dorn",
        location = "The Three Shields cave and rocky herb checks",
        routeType = "cave-check",
        density = "Localized",
        dropDifficulty = "Moderate. Check quickly, then continue the broader route if no nodes are up.",
        tips = {
            "Use the cave checks as a detour from the western Isle of Dorn gathering loop.",
            "Object pins near 24,57 and the Three Shields area support repeated Orbinid checks.",
        },
        coords = {
            C(0.244, 0.577, "Three Shields Orbinid check"),
            C(0.245, 0.574, "Cave-side Orbinid pin"),
            C(0.346, 0.735, "Three Shields south cave check"),
            C(0.349, 0.761, "Three Shields return"),
            C(0.352, 0.748, "Rocky Orbinid pocket"),
        },
        confidence = "medium",
    },
    {
        id = "orbinid-ringing-deeps-underground-route",
        source = "Wowhead Orbinid object map pins and herbalism overview",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "The Ringing Deeps",
        location = "General underground Orbinid route through northern and central tunnels",
        routeType = "underground-herb-loop",
        density = "Medium",
        dropDifficulty = "Better than surface-only routes because the zone matches Orbinid's cave and "
            .. "dark-spawn pattern.",
        tips = {
            "Use this as the broad farm after checking compact Isle of Dorn caves.",
            "Combine with Luredrop checks along the same underground route.",
            "Gather Irradiated variants for Leyline Residue while moving.",
        },
        coords = {
            C(0.373, 0.194, "Northern Orbinid wall"),
            C(0.376, 0.202, "North tunnel Orbinid pin"),
            C(0.382, 0.315, "Central tunnel Orbinid"),
            C(0.383, 0.302, "South bend Orbinid check"),
            C(0.386, 0.317, "Underground return"),
            C(0.412, 0.174, "Irradiated Orbinid extension"),
        },
        confidence = "high",
    },
}

local function RegisterHerb(itemID, itemName, qualityRank, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        qualityRank = qualityRank,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.method.gg/guides/the-war-within-herbalism-profession-leveling-guide",
        },
        summary = summary,
        spots = spots,
    })
end

RegisterHerb(210796, "Mycobloom", 1,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)
RegisterHerb(210797, "Mycobloom", 2,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)
RegisterHerb(210798, "Mycobloom", 3,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)

RegisterHerb(210805, "Blessing Blossom", 1,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })
RegisterHerb(210806, "Blessing Blossom", 2,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })
RegisterHerb(210807, "Blessing Blossom", 3,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })

Register({
    itemID = 210799,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 1,
    sourceUrls = {
        "https://www.wowhead.com/item=210799/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Comments point to hidden areas, caves, rare-spawn-adjacent places, "
        .. "darker Hallowfall pockets, The Ringing Deeps, and Azj-Kahet.",
    spots = LUREDROP_SPOTS,
})

Register({
    itemID = 210800,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 2,
    sourceUrls = {
        "https://www.wowhead.com/item=210800/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Target shaded pockets, caves, and underground routes rather than "
        .. "wide open surface herb loops.",
    spots = LUREDROP_SPOTS,
})

Register({
    itemID = 210801,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 3,
    sourceUrls = {
        "https://www.wowhead.com/item=210801/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Target shaded pockets, caves, and underground routes rather than "
        .. "wide open surface herb loops.",
    spots = LUREDROP_SPOTS,
})

Register({
    itemID = 210802,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 1,
    sourceUrls = {
        "https://www.wowhead.com/item=210802/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Wowhead comments repeatedly point to caves on "
        .. "Isle of Dorn and The Ringing Deeps.",
    spots = ORBINID_SPOTS,
})

Register({
    itemID = 210803,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 2,
    sourceUrls = {
        "https://www.wowhead.com/item=210803/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Use compact Isle of Dorn cave checks and "
        .. "Ringing Deeps tunnel loops.",
    spots = ORBINID_SPOTS,
})

Register({
    itemID = 210804,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 3,
    sourceUrls = {
        "https://www.wowhead.com/item=210804/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Use compact Isle of Dorn cave checks and "
        .. "Ringing Deeps tunnel loops.",
    spots = ORBINID_SPOTS,
})

RegisterHerb(210808, "Arathor's Spear", 1,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })
RegisterHerb(210809, "Arathor's Spear", 2,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })
RegisterHerb(210810, "Arathor's Spear", 3,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })

Register({
    itemID = 213197,
    itemName = "Null Lotus",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    sourceUrls = {
        "https://www.wowhead.com/item=213197/null-lotus",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
    },
    summary = "Rare Khaz Algar herb side gather. Farm any dense War Within herb route and value it as a "
        .. "bonus rare hit rather than a standalone node.",
    spots = H.TWW_HERB_SPOTS,
})
