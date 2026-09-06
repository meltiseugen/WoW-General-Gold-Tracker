local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local REVENDRETH_ARCHIVAM_CLOTH_ROUTE = {
    id = "shadowlands-revendreth-archivam-cloth-route",
    source = "wow-professions Shrouded Cloth and Lightless Silk farming guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/shrouded-cloth-farming",
        "https://www.wow-professions.com/farming/lightless-silk-farming",
    },
    mapName = "Revendreth",
    location = "Archivam humanoid packs in Revendreth",
    routeType = "cloth-farm",
    density = "High",
    dropDifficulty = "Easy to moderate. Fast respawns and tight packs, but neutral excavators require manual pulls.",
    tips = {
        "Farm Beleaguered Excavators, Excavation Enforcers, Nefarious Thugs, and Nefarious Collectors.",
        "Tailors get much better cloth returns because of Shadowlands Cloth Scavenging.",
        "Use Nourman nearby when bags fill up.",
    },
    coords = {
        C(0.684, 0.738, "Archivam west packs"),
        C(0.712, 0.712, "Archivam central packs"),
        C(0.742, 0.734, "Archivam east packs"),
        C(0.724, 0.772, "Southern return packs"),
    },
    confidence = "high",
}

local ARDENWEALD_TIRNA_NOCH_CLOTH_ROUTE = {
    id = "shadowlands-ardenweald-tirna-noch-cloth-route",
    source = "wow-professions Shrouded Cloth and Lightless Silk farming guides",
    sourceUrls = {
        "https://www.wow-professions.com/farming/shrouded-cloth-farming",
        "https://www.wow-professions.com/farming/lightless-silk-farming",
    },
    mapName = "Ardenweald",
    location = "Tirna Noch Blighted Fadeblade and Masked Soulsplitter route",
    routeType = "cloth-farm",
    density = "High",
    dropDifficulty = "Moderate. Very fast pulls, but mobs hit harder than the Revendreth route.",
    tips = {
        "Pull Blighted Fadeblades and Masked Soulsplitters in batches if your gear can handle it.",
        "Use Archivam if this route is too dangerous or if Revendreth is closer.",
        "Lightless Silk is rarer than Shrouded Cloth, so track long-session averages.",
    },
    coords = {
        C(0.640, 0.342, "Tirna Noch north packs"),
        C(0.666, 0.376, "Central soul packs"),
        C(0.628, 0.414, "Southwest fadeblade packs"),
        C(0.586, 0.374, "Western return packs"),
    },
    confidence = "high",
}

local ZERETH_MORTIS_PROTOFIBER_ROUTE = {
    id = "shadowlands-zereth-mortis-silken-protofiber-annelid-route",
    source = "Retail Wowhead Silken Protofiber comments, Annelid Duneborer and Engorged Annelid NPC pins, and World of Moudi 9.2 rare-farm notes",
    sourceUrls = {
        "https://www.wowhead.com/item=187703/silken-protofiber",
        "https://www.wowhead.com/npc=180706/annelid-duneborer",
        "https://www.wowhead.com/npc=180722/engorged-annelid",
        "https://www.worldofmoudi.com/silken-protofiber",
    },
    mapName = "Zereth Mortis",
    location = "Annelid Duneborer and Engorged Annelid clusters north and northeast of Pilgrim's Grace",
    routeType = "cloth-farm",
    density = "Localized",
    dropDifficulty = "Moderate to hard. The normal annelids are farmable, while Engorged Annelids are dangerous elite checks.",
    tips = {
        "Silken Protofiber is a Zereth Mortis cloth-style drop and does not require Tailoring to loot.",
        "Farm the annelid cluster around Pilgrim's Grace for repeatable pulls.",
        "Mother Phestis and Akkaris are useful rare checks when active, but this route keeps the repeatable mobs as the backbone.",
    },
    coords = {
        C(0.634, 0.382, "Annelid Duneborer west pin"),
        C(0.642, 0.384, "Annelid Duneborer route point"),
        C(0.644, 0.368, "Annelid Duneborer north bend"),
        C(0.654, 0.382, "Central duneborer cluster"),
        C(0.660, 0.396, "Central annelid return"),
        C(0.670, 0.376, "Eastern duneborer cluster"),
        C(0.672, 0.368, "Northern duneborer return"),
        C(0.674, 0.358, "Northeast duneborer pin"),
        C(0.676, 0.330, "North annelid pin"),
        C(0.688, 0.334, "Far northeast duneborer pin"),
        C(0.680, 0.342, "Engorged Annelid northeast pin"),
        C(0.694, 0.340, "Engorged Annelid east pin"),
        C(0.550, 0.330, "Mother Phestis rare check cave"),
        C(0.6467, 0.3382, "Akkaris rare check"),
    },
    confidence = "high",
}

local function RegisterCloth(itemID, itemName, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "shadowlands",
        professions = { "tailoring" },
        category = "Cloth",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = {
            REVENDRETH_ARCHIVAM_CLOTH_ROUTE,
            ARDENWEALD_TIRNA_NOCH_CLOTH_ROUTE,
        },
    })
end

RegisterCloth(173202, "Shrouded Cloth",
    "Common Shadowlands cloth from humanoid farming routes; tailors get far better returns.")
RegisterCloth(173204, "Lightless Silk",
    "Rare Shadowlands cloth from the same mobs as Shrouded Cloth, at lower drop rate.")
Register({
    itemID = 187703,
    itemName = "Silken Protofiber",
    expansion = "shadowlands",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = { ItemUrl(187703) },
    summary = "Patch 9.2 Zereth Mortis cloth-style material from annelids, spiders, and select rares.",
    spots = { ZERETH_MORTIS_PROTOFIBER_ROUTE },
})
