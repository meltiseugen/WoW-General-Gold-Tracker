local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local ORE_GUIDE = "https://www.wowhead.com/guide/classic-mining-best-farming-basics-early-ores"
local MINING_GUIDE = "https://www.wowhead.com/guide/mining-leveling-1-300-wow-classic"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local GEM_ROUTES = {
    copper = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/copper-ore-farming",
            "https://artisansofazeroth.com/copper-ore-farming/",
            "https://www.wowhead.com/object=1731/copper-vein",
        },
        mapName = "Durotar",
        location = "Copper node turnover around Skull Rock, Razor Hill ridges, Drygulch, and southern Durotar",
        density = "Common side drop from Copper",
        coords = {
            C(0.530, 0.210, "Skull Rock Copper cluster"),
            C(0.540, 0.295, "Razor Hill north ridge"),
            C(0.487, 0.374, "Razor Hill western rocks"),
            C(0.438, 0.482, "Drygulch Ravine approach"),
            C(0.597, 0.580, "Southern ridge Copper"),
        },
        tips = {
            "Farm the ore, not individual gem mobs; low gems are mining side results.",
            "Clear every Copper node to keep Malachite, Tigerseye, and Shadowgem chances cycling.",
        },
    },
    tin = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/tin-ore-farming",
            "https://artisansofazeroth.com/tin-ore-farming/",
            "https://www.wowhead.com/object=1732/tin-vein",
        },
        mapName = "Hillsbrad Foothills",
        location = "Tin route through Hillsbrad and Alterac foothill mountain pins",
        density = "Common side drop from Tin",
        coords = {
            C(0.7357, 0.5904, "Alterac foothill Tin"),
            C(0.7178, 0.6437, "Darrow Hill north Tin"),
            C(0.6506, 0.6889, "Darrow Hill outer Tin"),
            C(0.6165, 0.7276, "Ruins ridge south Tin"),
            C(0.5596, 0.7336, "Western ridge Tin"),
            C(0.6223, 0.4617, "Alterac mountain spur Tin"),
            C(0.7148, 0.5611, "Route return Tin"),
        },
        tips = {
            "Use Tin routes for Moss Agate, Lesser Moonstone, and Shadowgem.",
            "Silver replacement nodes can appear while doing the same loop.",
        },
    },
    iron = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/iron-ore-farming",
            "https://www.wowhead.com/object=1735/iron-deposit",
        },
        mapName = "Arathi Highlands",
        location = "Iron route around Arathi ridges, binding circles, and Stromgarde rocks",
        density = "Common to uncommon side drop from Iron",
        coords = {
            C(0.276, 0.375, "Northfold Manor Iron"),
            C(0.386, 0.305, "Circle of West Binding Iron"),
            C(0.484, 0.456, "Central Arathi Iron"),
            C(0.600, 0.560, "Dabyrie's Farmstead Iron"),
            C(0.308, 0.745, "Stromgarde outer rocks"),
        },
        tips = {
            "Iron routes are useful for Jade, Citrine, Lesser Moonstone, Aquamarine, and rare Star Ruby.",
            "Gold replacement nodes add extra value on the same path.",
        },
    },
    mithril = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/mithril-ore-farming",
            "https://artisansofazeroth.com/mithril-ore-farming/",
            "https://www.wowhead.com/object=2040/mithril-deposit",
        },
        mapName = "Badlands",
        location = "Mithril route around Camp Cagg, Dustbowl, Agmond's End, and Lethlor Ravine",
        density = "Common to uncommon side drop from Mithril",
        coords = {
            C(0.1136, 0.3685, "Badlands west Mithril"),
            C(0.2440, 0.3848, "Dustbowl northwest Mithril"),
            C(0.4767, 0.1342, "Lethlor north wall Mithril"),
            C(0.5604, 0.2112, "Lethlor Ravine rim"),
            C(0.5746, 0.3898, "Ravine southeast Mithril"),
            C(0.5730, 0.5392, "Agmond's End Mithril"),
            C(0.2405, 0.6430, "Dustbelch approach Mithril"),
        },
        tips = {
            "Badlands gives compact Mithril turnover for Aquamarine, Citrine, and Star Ruby chances.",
            "Clear Mithril deposits to create Truesilver replacement chances.",
        },
    },
    thorium = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/thorium-ore-farming",
            "https://artisansofazeroth.com/thorium-ore-farming/",
            "https://www.wowhead.com/object=175404/rich-thorium-vein",
        },
        mapName = "Winterspring",
        location = "Winterspring outer wall Thorium route for Arcane Crystal and high-end gem side drops",
        density = "Uncommon to rare side drop from Thorium",
        coords = {
            C(0.3121, 0.6533, "Owl Wing Thicket Thorium"),
            C(0.2861, 0.4804, "Winterfall Village west Thorium"),
            C(0.2879, 0.1102, "Frostsaber north Thorium"),
            C(0.4758, 0.1970, "Starfall Village north Thorium"),
            C(0.6932, 0.1642, "Mazthoril north Thorium"),
            C(0.7225, 0.4003, "East wall Thorium"),
            C(0.6324, 0.4841, "South-east ridge Thorium"),
            C(0.6430, 0.8341, "Darkwhisper south wall Thorium"),
            C(0.2533, 0.7995, "Western south wall Thorium"),
        },
        tips = {
            "Rich Thorium is the priority for Arcane Crystal and high-end gems.",
            "Use the Winterspring outer wall to keep Rich Thorium and high-end gem turnover high.",
        },
    },
}

local function RegisterGem(itemID, itemName, professions, summary, routeKeys)
    local spots = {}
    local sourceUrls = { ItemUrl(itemID), ORE_GUIDE, MINING_GUIDE }
    for _, routeKey in ipairs(routeKeys) do
        local route = GEM_ROUTES[routeKey]
        for _, url in ipairs(route.urls) do
            sourceUrls[#sourceUrls + 1] = url
        end
        spots[#spots + 1] = {
            id = "classic-gem-" .. tostring(itemID) .. "-" .. routeKey,
            source = "Wowhead retail mining object pages, Wowhead comments, wow-professions routes, and Artisans of Azeroth route pins",
            sourceUrls = route.urls,
            mapName = route.mapName,
            location = route.location,
            routeType = "mining-side-drop",
            density = route.density,
            dropDifficulty = "Gem side material from mining nodes. Treat it as a bonus while farming the matching ore tier.",
            tips = route.tips,
            coords = route.coords,
            confidence = "high",
        }
    end

    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = professions,
        category = "Gem",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterGem(774, "Malachite", { "jewelcrafting", "blacksmithing", "engineering" }, "Low-level gem from Copper nodes and early mining. Best farm is dense Copper turnover.", { "copper" })
RegisterGem(818, "Tigerseye", { "jewelcrafting", "blacksmithing", "engineering" }, "Low-level gem from Copper nodes. Farm starter Copper loops for volume.", { "copper" })
RegisterGem(1210, "Shadowgem", { "jewelcrafting", "blacksmithing", "engineering" }, "Low-level gem most practically farmed from Tin routes, with Copper as a weaker backup.", { "tin", "copper" })
RegisterGem(1206, "Moss Agate", { "jewelcrafting", "blacksmithing", "engineering" }, "Tin-tier gem from Tin nodes and early mid-level mining routes.", { "tin" })
RegisterGem(1705, "Lesser Moonstone", { "jewelcrafting", "blacksmithing", "engineering" }, "Tin and Iron-tier gem. Tin routes are clean; Iron routes add higher-value side materials.", { "tin", "iron" })
RegisterGem(1529, "Jade", { "jewelcrafting", "blacksmithing", "engineering" }, "Iron-tier gem with occasional Tin-route appearances. Farm Iron loops when targeting it directly.", { "iron", "tin" })
RegisterGem(3864, "Citrine", { "jewelcrafting", "blacksmithing", "engineering" }, "Iron and Mithril-tier gem. Arathi Iron or Badlands Mithril routes are practical depending on other targets.", { "iron", "mithril" })
RegisterGem(7909, "Aquamarine", { "jewelcrafting", "blacksmithing", "engineering" }, "Mithril-tier gem also found from Iron and Truesilver. Badlands Mithril loops are the best direct target.", { "mithril", "iron" })
RegisterGem(7910, "Star Ruby", { "jewelcrafting", "blacksmithing", "engineering" }, "High-value gem from Mithril and Thorium routes, with rare Iron-route appearances.", { "mithril", "thorium" })
RegisterGem(12361, "Blue Sapphire", { "jewelcrafting" }, "High-end gem from Thorium routes, especially Rich Thorium node turnover.", { "thorium" })
RegisterGem(12363, "Arcane Crystal", { "jewelcrafting", "blacksmithing", "engineering" }, "Rare high-end crystal from Rich Thorium Veins. Farm Rich Thorium density rather than normal Thorium volume.", { "thorium" })
RegisterGem(12364, "Huge Emerald", { "jewelcrafting" }, "High-end gem from Thorium routes, particularly Rich Thorium nodes.", { "thorium" })
RegisterGem(12799, "Large Opal", { "jewelcrafting" }, "High-end gem from Small and Rich Thorium nodes.", { "thorium" })
RegisterGem(12800, "Azerothian Diamond", { "jewelcrafting" }, "High-end gem from Rich Thorium routes. Winterspring is the practical dense route.", { "thorium" })
