local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local FEL_IRON_COORDS = {
    { x = 0.062, y = 0.494, label = "Western Hellfire Fel Iron node" },
    { x = 0.103, y = 0.555, label = "Thornfang Hill Fel Iron node" },
    { x = 0.334, y = 0.499, label = "Hellfire Citadel approach node" },
    { x = 0.694, y = 0.435, label = "Zeth'gor cliff node" },
    { x = 0.706, y = 0.734, label = "Southern Hellfire node" },
}

local ADAMANTITE_COORDS = {
    { x = 0.071, y = 0.399, label = "Twilight Ridge Adamantite node" },
    { x = 0.232, y = 0.278, label = "Northwest Nagrand ridge node" },
    { x = 0.292, y = 0.541, label = "Western Nagrand cave node" },
    { x = 0.431, y = 0.622, label = "Central Nagrand ridge node" },
    { x = 0.698, y = 0.725, label = "Southeast Nagrand ridge node" },
}

local ADAMANTITE_PROSPECTING_COORDS = {
    { x = 0.610, y = 0.440, label = "Isle northeast waterline Adamantite node" },
    { x = 0.600, y = 0.400, label = "Isle northeast hillside node" },
    { x = 0.620, y = 0.400, label = "Isle northeast upper hillside node" },
    { x = 0.370, y = 0.510, label = "Sunwell Plateau lower shelf node" },
    { x = 0.360, y = 0.440, label = "Northwest inner shelf node" },
    { x = 0.350, y = 0.350, label = "Northwest high shelf node" },
    { x = 0.390, y = 0.350, label = "Dawnstar Village high shelf node" },
    { x = 0.430, y = 0.320, label = "Dawnstar Village ridge node" },
    { x = 0.450, y = 0.370, label = "North Dawning Square node" },
    { x = 0.500, y = 0.410, label = "Dawning Square west shelf node" },
    { x = 0.490, y = 0.460, label = "Sun's Reach shelf node" },
    { x = 0.470, y = 0.500, label = "Sun's Reach Armory node" },
}

local function RegisterGem(itemID, itemName, rarity, coords, mapName, sourceNode)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "jewelcrafting" },
        category = "Gem",
        researchStatus = "researched",
        sourceUrls = {
            "https://www.wowhead.com/item=" .. itemID,
            "https://www.wowhead.com/object=181555/fel-iron-deposit",
            "https://www.wowhead.com/object=181556/adamantite-deposit",
        },
        summary = itemName .. " is a " .. rarity .. " Burning Crusade prospecting gem. The practical farm is mining/prospecting " .. sourceNode .. " rather than looking for loose gem drops.",
        spots = {
            {
                id = "bc-gem-" .. itemID .. "-prospecting-route",
                source = "Wowhead ore-node map pins and TBC prospecting tables",
                sourceUrls = {
                    "https://www.wowhead.com/item=" .. itemID,
                    "https://www.wowhead.com/object=181555/fel-iron-deposit",
                    "https://www.wowhead.com/object=181556/adamantite-deposit",
                },
                mapName = mapName,
                location = sourceNode .. " mining route for prospecting",
                routeType = "prospecting-input-route",
                density = "Depends on ore supply",
                dropDifficulty = "Indirect. Mine ore first, then prospect it with Jewelcrafting.",
                tips = {
                    "Track the gem together with the ore route that feeds it.",
                    "Use raw ore value versus expected prospecting value before committing to a long route.",
                },
                coords = coords,
                confidence = "high",
            },
        },
    })
end

for _, gem in ipairs({
    { 23077, "Blood Garnet" },
    { 23079, "Deep Peridot" },
    { 21929, "Flame Spessarite" },
    { 23112, "Golden Draenite" },
    { 23107, "Shadow Draenite" },
    { 23117, "Azure Moonstone" },
}) do
    RegisterGem(gem[1], gem[2], "common", FEL_IRON_COORDS, "Hellfire Peninsula", "Fel Iron Ore")
end

for _, gem in ipairs({
    { 23436, "Living Ruby" },
    { 23437, "Talasite" },
    { 23438, "Star of Elune" },
    { 23439, "Noble Topaz" },
    { 23440, "Dawnstone" },
    { 23441, "Nightseye" },
}) do
    RegisterGem(gem[1], gem[2], "rare", ADAMANTITE_COORDS, "Nagrand", "Adamantite Ore")
end

Register({
    itemID = 24243,
    itemName = "Adamantite Powder",
    expansion = "burningCrusade",
    professions = { "jewelcrafting", "mining" },
    category = "Powder",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=24243/adamantite-powder",
        "https://warcraft.wiki.gg/wiki/Adamantite_Powder",
        "https://www.wowhead.com/object=181556/adamantite-deposit",
    },
    summary = "Jewelcrafting reagent acquired by prospecting Adamantite Ore. The practical farm is dense Adamantite mining, then prospecting the ore rather than hunting powder as a world drop.",
    spots = {
        {
            id = "adamantite-powder-isle-queldanas-prospecting-route",
            source = "Retail Wowhead Adamantite Powder comments and Adamantite Deposit map pins",
            sourceUrls = {
                "https://www.wowhead.com/item=24243/adamantite-powder",
                "https://www.wowhead.com/object=181556/adamantite-deposit",
            },
            mapName = "Isle of Quel'Danas",
            location = "East coastline and northwest Sunwell Plateau Adamantite nodes for prospecting",
            routeType = "prospecting-input-route",
            density = "Medium to high when uncontested",
            dropDifficulty = "Indirect. Mine Adamantite Ore first, then prospect it with Jewelcrafting.",
            tips = {
                "The compact Isle route is useful when powder demand beats raw Adamantite Ore value.",
                "Clear every Adamantite-capable node and treat Khorium as a rare replacement bonus.",
            },
            coords = ADAMANTITE_PROSPECTING_COORDS,
            confidence = "medium",
        },
    },
})
