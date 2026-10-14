local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local BASTION_CLOUDSTRIDER_ROUTE = {
    id = "shadowlands-bastion-gilded-cloudstrider-skinning",
    source = "wow-professions Shadowlands leather guides and Wowhead skinning guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/desolate-leather-farming",
        "https://www.wow-professions.com/farming/callous-hide-farming",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Bastion",
    location = "Gilded Cloudstrider hill packs in Bastion",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Easy. Fast respawns and large pulls make this a good general leather route.",
    tips = {
        "Pull both sides of the hill because the cloudstriders spawn across the slope.",
        "Use the Shadowlands Gathering glove enchant to cut skinning time sharply.",
        "Leather is not zone-specific, so use this route when you want speed and easy terrain.",
    },
    coords = {
        C(0.456, 0.596, "West cloudstrider slope"),
        C(0.492, 0.624, "Hilltop pack"),
        C(0.532, 0.586, "East slope pack"),
        C(0.516, 0.536, "North return pack"),
    },
    confidence = "high",
}

local BASTION_ETHERWYRM_ROUTE = {
    id = "shadowlands-bastion-etherwyrm-skinning",
    source = "wow-professions Shadowlands leather guides and Wowhead skinning guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/desolate-leather-farming",
        "https://www.wow-professions.com/farming/callous-hide-farming",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Bastion",
    location = "Languishing and Starved Etherwyrm pocket in Bastion",
    routeType = "skinning-loop",
    density = "Medium to high",
    dropDifficulty = "Easy, though the starter quest area can be busy.",
    tips = {
        "Tag etherwyrms quickly when other players are questing nearby.",
        "Use this as a backup when the cloudstrider hill is crowded.",
        "This remains useful for Callous Hide because all Shadowlands skinnable mobs can drop the rare hides.",
    },
    coords = {
        C(0.548, 0.442, "North etherwyrm pocket"),
        C(0.592, 0.466, "East etherwyrm pack"),
        C(0.604, 0.526, "South ridge pack"),
        C(0.520, 0.514, "Western return"),
    },
    confidence = "high",
}

local MALDRAXXUS_BEAST_ROUTE = {
    id = "shadowlands-maldraxxus-bonetooth-tauralus-skinning",
    source = "wow-professions Shadowlands leather guides and Wowhead skinning guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/desolate-leather-farming",
        "https://www.wow-professions.com/farming/callous-hide-farming",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Maldraxxus",
    location = "Neonate Bonetooth, Bloodskin Tauralus, and Furious Alphahoof route",
    routeType = "skinning-loop",
    density = "High",
    dropDifficulty = "Moderate. Strong pulls, but mobs have more health than simpler Bastion packs.",
    tips = {
        "Follow the beast route and pull six or more at a time if your character can handle it.",
        "Use this when you also want Maldraxxus meat and Marrowroot side checks.",
        "Avoid spider-heavy pockets that are not skinnable.",
    },
    coords = {
        C(0.486, 0.564, "West bonetooth packs"),
        C(0.538, 0.596, "Central tauralus packs"),
        C(0.596, 0.552, "East alphahoof packs"),
        C(0.566, 0.646, "Southern return packs"),
    },
    confidence = "high",
}

local MALDRAXXUS_PEST_ROUTE = {
    id = "shadowlands-maldraxxus-virulent-pest-skinning",
    source = "wow-professions Shadowlands leather guides and Wowhead skinning guide",
    sourceUrls = {
        "https://www.wow-professions.com/farming/desolate-leather-farming",
        "https://www.wow-professions.com/farming/callous-hide-farming",
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Maldraxxus",
    location = "Virulent Pest fast-respawn pocket",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Mobs are spread out, but fast respawn keeps the route moving.",
    tips = {
        "Keep moving between pest pockets instead of waiting on one spawn point.",
        "Good backup route if the main beast loop is contested.",
        "Skinning level improves leather yield, so keep training while farming.",
    },
    coords = {
        C(0.622, 0.724, "North pest pocket"),
        C(0.664, 0.756, "East pest pocket"),
        C(0.642, 0.812, "South pest pocket"),
        C(0.584, 0.786, "West return pest pocket"),
    },
    confidence = "medium",
}

local REVENDRETH_BEAST_ROUTE = {
    id = "shadowlands-revendreth-wanecrypt-darkhaven-skinning",
    source = "Wowhead Shadowlands skinning guide",
    sourceUrls = {
        "https://www.wowhead.com/guide/shadowlands-skinning-profession",
    },
    mapName = "Revendreth",
    location = "Lower Revendreth south of Castle Nathria between Wanecrypt Hill and Darkhaven",
    routeType = "skinning-loop",
    density = "Medium",
    dropDifficulty = "Moderate. Good bear, bat, and hound route, but avoid unskinnable gargons near towns.",
    tips = {
        "Stay in the lower middle half of Revendreth rather than dense urban blocks.",
        "Bears, bats, and hounds are the practical targets here.",
        "Use Bastion or Ardenweald if pure leather speed matters more than Revendreth side value.",
    },
    coords = {
        C(0.462, 0.684, "Wanecrypt-side beast packs"),
        C(0.524, 0.704, "Lower road packs"),
        C(0.590, 0.652, "Darkhaven-side loop"),
        C(0.548, 0.596, "North return packs"),
    },
    confidence = "medium",
}

local ZERETH_MORTIS_PROTOGENIC_PELT_ROUTE = {
    id = "shadowlands-zereth-mortis-protogenic-pelt-skinning-route",
    source = "Retail Wowhead Protogenic Pelt comments and Ravenous Cervid, Engorged Annelid, and skinnable rare NPC pins",
    sourceUrls = {
        "https://www.wowhead.com/item=187701/protogenic-pelt",
        "https://www.wowhead.com/npc=182272/ravenous-cervid",
        "https://www.wowhead.com/npc=180722/engorged-annelid",
        "https://www.wowhead.com/npc=181360/vexis",
        "https://www.wowhead.com/npc=179006/akkaris",
    },
    mapName = "Zereth Mortis",
    location = "Ravenous Cervid packs near Dimensional Falls plus Engorged Annelid and rare-skinning checks",
    routeType = "skinning-loop",
    density = "Localized for farmable mobs, opportunistic for rares",
    dropDifficulty = "Moderate to hard. Cervids are safer; Engorged Annelids and rares hit much harder but can yield better pelts.",
    tips = {
        "Train Shadowlands Skinning before farming; the pelt can fail to appear if you only skin with old ranks.",
        "Ravenous Cervids are the safer repeatable farm, while Engorged Annelids are harder elite checks.",
        "Skinnable Zereth Mortis rares are worth checking if you arrive before the corpse despawns.",
    },
    coords = {
        C(0.494, 0.664, "Ravenous Cervid west Dimensional Falls pin"),
        C(0.496, 0.668, "Ravenous Cervid west pack"),
        C(0.522, 0.666, "Ravenous Cervid central pack"),
        C(0.524, 0.642, "Ravenous Cervid north pack"),
        C(0.526, 0.646, "Ravenous Cervid north return"),
        C(0.548, 0.664, "Ravenous Cervid east pack"),
        C(0.644, 0.394, "Engorged Annelid western elite pin"),
        C(0.668, 0.344, "Engorged Annelid north elite pin"),
        C(0.680, 0.342, "Engorged Annelid northeast pin"),
        C(0.694, 0.340, "Engorged Annelid east elite pin"),
        C(0.392, 0.564, "Vexis skinnable rare pack"),
        C(0.646, 0.334, "Akkaris rare pelt check"),
    },
    confidence = "high",
}

local SKINNING_SPOTS = {
    BASTION_CLOUDSTRIDER_ROUTE,
    BASTION_ETHERWYRM_ROUTE,
    MALDRAXXUS_BEAST_ROUTE,
    MALDRAXXUS_PEST_ROUTE,
    REVENDRETH_BEAST_ROUTE,
    ZERETH_MORTIS_PROTOGENIC_PELT_ROUTE,
}

local function RegisterSkinning(itemID, itemName, summary, category)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "skinning", "leatherworking" },
        category = category or "Leather",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = SKINNING_SPOTS,
    })
end

RegisterSkinning(172089, "Desolate Leather",
    "Common Shadowlands skinning leather from skinnable beasts across all covenant zones.")
RegisterSkinning(172092, "Pallid Bone", "Shadowlands skinning bone side material from skinnable beasts.")
RegisterSkinning(172094, "Callous Hide",
    "Rare Shadowlands hide from skinnable mobs; farm the same dense leather routes.", "Hide")
RegisterSkinning(172096, "Heavy Desolate Leather",
    "Gathered and crafted Shadowlands leather; farm dense skinnable packs for direct drops and leather volume.")
RegisterSkinning(172097, "Heavy Callous Hide",
    "Rare gathered and crafted Shadowlands hide; dense routes maximize direct drop chances.", "Hide")
Register({
    itemID = 187701,
    itemName = "Protogenic Pelt",
    expansion = "shadowlands",
    professions = { "skinning", "leatherworking" },
    category = "Hide",
    sourceUrls = { ItemUrl(187701) },
    summary = "Patch 9.2 Zereth Mortis hide from stronger skinnable creatures, farmable cervids, Engorged Annelids, and skinnable rares.",
    spots = { ZERETH_MORTIS_PROTOGENIC_PELT_ROUTE },
})
