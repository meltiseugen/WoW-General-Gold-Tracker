local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ZERETH_MORTIS_PROGENITOR_ESSENTIA_ROUTE = {
    id = "shadowlands-zereth-mortis-progenitor-essentia-gathering-route",
    source = "Retail Wowhead Progenitor Essentia item page, Patch 9.2 profession guide, Progenium/First Flower object pins, and Zereth Mortis fishing/NPC comments",
    sourceUrls = {
        "https://www.wowhead.com/item=187707/progenitor-essentia",
        "https://www.wowhead.com/guide/profession-updates-patch-9-2-vestige-of-the-eternal",
        "https://www.wowhead.com/object=370400/progenium-deposit",
        "https://www.wowhead.com/object=370398/first-flower",
        "https://www.wowhead.com/item=187702/precursor-placoderm",
        "https://www.wowhead.com/npc=180706/annelid-duneborer",
        "https://artisansofazeroth.com/progenium-ore-frist-flower-route-zereth-mortis/",
    },
    mapName = "Zereth Mortis",
    location = "Gathering-first Zereth Mortis route through northern Progenium/First Flower pins, Haven fishing water, and Pilgrim's Grace creature checks",
    routeType = "rare-side-gather-route",
    density = "Rare side gather",
    dropDifficulty = "Hard. Progenitor Essentia is a rare side material, so farm high-volume Zereth Mortis activities instead of camping one point.",
    tips = {
        "Use mining and herbalism on the northern loop when possible because both Progenium and First Flower can award it.",
        "Fish the Haven cave or Dimensional Falls when gathering routes are crowded.",
        "Add Pilgrim's Grace annelid pulls or rare checks if also targeting pelt, protofiber, or protoflesh.",
    },
    coords = {
        C(0.5005, 0.2543, "Northern gathering loop start"),
        C(0.5944, 0.2443, "Northern Progenium and First Flower checks"),
        C(0.6234, 0.2120, "Object-pin overlap"),
        C(0.6551, 0.2140, "Northeastern object route"),
        C(0.6719, 0.2668, "Northeast gathering bend"),
        C(0.6931, 0.3355, "Eastern object-pin cluster"),
        C(0.6171, 0.3441, "Southern gathering return"),
        C(0.3301, 0.6963, "Haven cave fishing pool"),
        C(0.518, 0.745, "Dimensional Falls fishing water"),
        C(0.680, 0.342, "Pilgrim's Grace annelid check"),
        C(0.646, 0.334, "Akkaris rare check"),
    },
    confidence = "medium",
}

Register({
    itemID = 187707,
    itemName = "Progenitor Essentia",
    expansion = "shadowlands",
    professions = {
        "mining",
        "herbalism",
        "skinning",
        "fishing",
        "alchemy",
        "blacksmithing",
        "engineering",
        "jewelcrafting",
        "leatherworking",
        "tailoring",
    },
    category = "Reagent",
    sourceUrls = { ItemUrl(187707) },
    summary = "Rare Patch 9.2 Zereth Mortis reagent from gathering, fishing, treasures, and other high-volume zone activity.",
    spots = { ZERETH_MORTIS_PROGENITOR_ESSENTIA_ROUTE },
})
