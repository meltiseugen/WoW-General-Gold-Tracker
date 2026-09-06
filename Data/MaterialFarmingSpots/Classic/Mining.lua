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

local COPPER_DUROTAR = {
    C(0.5449, 0.1109, "Skull Rock north ridge"),
    C(0.5435, 0.1407, "Skull Rock cave approach"),
    C(0.5859, 0.1732, "Northeast Durotar rocks"),
    C(0.5063, 0.1741, "Drygulch north rocks"),
    C(0.4983, 0.2114, "Drygulch ridge"),
    C(0.5204, 0.2461, "Razor Hill north ridge"),
    C(0.5627, 0.2553, "Tiragarde north rocks"),
    C(0.5602, 0.3107, "Tiragarde approach"),
    C(0.5067, 0.2701, "Razor Hill west spur"),
    C(0.4512, 0.2488, "Razor Hill northwest rocks"),
    C(0.4910, 0.3322, "Razor Hill west pass"),
    C(0.4753, 0.3644, "Razor Hill southwest ridge"),
    C(0.5297, 0.3459, "Razor Hill south rocks"),
    C(0.5578, 0.4990, "Sen'jin approach ridge"),
    C(0.4755, 0.4855, "Drygulch south rocks"),
    C(0.3678, 0.5647, "Southfury western ridge"),
    C(0.3701, 0.4605, "Drygulch Ravine south"),
    C(0.4305, 0.3881, "Razor Hill southwest pass"),
    C(0.3589, 0.3476, "Western Durotar rocks"),
    C(0.3877, 0.1532, "Northwest Durotar ridge"),
}

local TIN_HILLSBRAD = {
    C(0.7357, 0.5904, "Alterac foothill east"),
    C(0.7507, 0.6028, "Darrow Hill northeast ridge"),
    C(0.7178, 0.6437, "Darrow Hill north"),
    C(0.6979, 0.6712, "Darrow Hill west ridge"),
    C(0.6506, 0.6889, "Darrow Hill outer rocks"),
    C(0.6705, 0.7158, "Eastern mountain pocket"),
    C(0.6663, 0.7555, "Southeast mountain pass"),
    C(0.6395, 0.7644, "South mountain wall"),
    C(0.6165, 0.7276, "Ruins ridge south"),
    C(0.6010, 0.7686, "Southwest mountain rocks"),
    C(0.5872, 0.7646, "Southwest foothill"),
    C(0.5596, 0.7336, "Western ridge"),
    C(0.5662, 0.6961, "Western mountain pocket"),
    C(0.6165, 0.6644, "Central ridge return"),
    C(0.5913, 0.6352, "Foothill connector"),
    C(0.6325, 0.6084, "North return rocks"),
    C(0.6223, 0.4617, "Alterac mountain spur"),
    C(0.6628, 0.5356, "East ridge connector"),
    C(0.6833, 0.5479, "Northeast foothill"),
    C(0.7148, 0.5611, "Route return ridge"),
}

local IRON_ARATHI = {
    C(0.276, 0.375, "Northfold Manor ridge"),
    C(0.386, 0.305, "Circle of West Binding ridge"),
    C(0.484, 0.456, "Central Arathi highlands"),
    C(0.600, 0.560, "Dabyrie's Farmstead hills"),
    C(0.730, 0.388, "Hammerfall eastern ridge"),
    C(0.308, 0.745, "Stromgarde outer rocks"),
}

local MITHRIL_BADLANDS = {
    C(0.1136, 0.3685, "Badlands west ridge"),
    C(0.1652, 0.3623, "Angor Fortress west"),
    C(0.2044, 0.3649, "Angor road rocks"),
    C(0.2440, 0.3848, "Dustbowl northwest"),
    C(0.2733, 0.3718, "Dustbowl ridge"),
    C(0.3061, 0.3753, "Central ridge"),
    C(0.3730, 0.3242, "Camp Cagg north rocks"),
    C(0.4495, 0.2585, "Lethlor west rise"),
    C(0.4767, 0.1342, "Lethlor north wall"),
    C(0.5246, 0.1689, "Lethlor upper ridge"),
    C(0.5604, 0.2112, "Lethlor Ravine rim"),
    C(0.5927, 0.3117, "Eastern Lethlor rocks"),
    C(0.5746, 0.3898, "Ravine southeast"),
    C(0.5629, 0.4573, "Agmond connector"),
    C(0.5730, 0.5392, "Agmond's End ridge"),
    C(0.5813, 0.5966, "Southern Agmond rocks"),
    C(0.5309, 0.6244, "South Badlands wall"),
    C(0.4749, 0.6416, "Camp Cagg south ridge"),
    C(0.4158, 0.6584, "Western south ridge"),
    C(0.2405, 0.6430, "Dustbelch approach"),
    C(0.1209, 0.6352, "Far west return"),
}

local THORIUM_WINTERSPRING = {
    C(0.3121, 0.6533, "Owl Wing Thicket ridge"),
    C(0.2405, 0.5613, "Frostfire Hot Springs west"),
    C(0.2861, 0.4804, "Winterfall Village west"),
    C(0.2727, 0.4170, "Lake Kel'Theril west"),
    C(0.2832, 0.3795, "Lake Kel'Theril north"),
    C(0.2597, 0.2921, "Frostsaber approach"),
    C(0.2879, 0.1102, "Frostsaber Rock north"),
    C(0.3493, 0.1262, "Frostsaber east ridge"),
    C(0.3566, 0.2363, "Northern ridge return"),
    C(0.4040, 0.1476, "North central rocks"),
    C(0.4758, 0.1970, "Starfall Village north"),
    C(0.5914, 0.1139, "Northeast Winterspring"),
    C(0.6932, 0.1642, "Mazthoril north"),
    C(0.6821, 0.2652, "Mazthoril west wall"),
    C(0.7225, 0.4003, "East wall ridge"),
    C(0.6920, 0.4520, "Everlook east wall"),
    C(0.6462, 0.4534, "Everlook southeast rocks"),
    C(0.5780, 0.4323, "Everlook south connector"),
    C(0.5613, 0.4083, "Central return ridge"),
    C(0.5550, 0.4685, "Central gorge rim"),
    C(0.6324, 0.4841, "South-east ridge"),
    C(0.6748, 0.5694, "Ice Thistle ridge"),
    C(0.6701, 0.6311, "Darkwhisper north"),
    C(0.6940, 0.6899, "Darkwhisper east"),
    C(0.6430, 0.8341, "Darkwhisper south wall"),
    C(0.5471, 0.8162, "Southern return ridge"),
    C(0.4908, 0.7964, "Owl Wing south wall"),
    C(0.4074, 0.8065, "Southwest ridge"),
    C(0.2533, 0.7995, "Western south wall"),
    C(0.3034, 0.6952, "Owl Wing return"),
}

local DARK_IRON_SEARING_GORGE = {
    C(0.346, 0.266, "Thorium Point south ridge"),
    C(0.426, 0.382, "Cauldron northwest rim"),
    C(0.512, 0.446, "Cauldron inner ramp"),
    C(0.604, 0.380, "Grimesilt Dig Site approach"),
    C(0.666, 0.548, "Dustfire Valley approach"),
    C(0.358, 0.744, "Blackrock Mountain approach"),
}

local ROUTES = {
    copper = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/copper-ore-farming",
            "https://artisansofazeroth.com/copper-ore-farming/",
            "https://www.wowhead.com/object=1731/copper-vein",
        },
        mapName = "Durotar",
        location = "Durotar outer ridge and cave loop, with Skull Rock, Razor Hill, Drygulch, and southern ridge checks",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Easy starter route. Copper nodes also supply Rough Stone and low-tier gems.",
        tips = {
            "Keep to ridges, cave mouths, and rocky edges rather than crossing empty open ground.",
            "Skip Echo Isles if you only want ore speed; add it if competition is heavy.",
            "Mine every Copper node completely to keep low-tier gem turnover moving.",
        },
        coords = COPPER_DUROTAR,
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
        location = "Hillsbrad and Alterac foothill mountain loop for Tin and rare Silver replacement nodes",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Good low-mid route. Tin nodes can produce Coarse Stone, Moss Agate, Shadowgem, and rare Silver.",
        tips = {
            "Use the southern route first; it has stronger Tin density around Bael Modan.",
            "Clear Copper too when moving between Tin pockets so replacement nodes keep cycling.",
            "Treat Silver as a bonus from Tin turnover rather than a campable route target.",
        },
        coords = TIN_HILLSBRAD,
    },
    iron = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/iron-ore-farming",
            "https://www.wowhead.com/object=1735/iron-deposit",
        },
        mapName = "Arathi Highlands",
        location = "Outer ridge and Stromgarde-adjacent Arathi loop for Iron and rare Gold replacement nodes",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Good mid-level route, though faction travel and quest traffic can slow early characters.",
        tips = {
            "Follow mountain walls and Stromgarde-adjacent rocks instead of crossing the central roads.",
            "Gold comes from Iron-family replacement behavior, so keep the full Iron route moving.",
            "Arathi pairs well with Kingsblood, Goldthorn, Heavy Leather, and elemental side farms.",
        },
        coords = IRON_ARATHI,
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
        location = "Badlands Camp Cagg, Dustbowl, Agmond's End, and Lethlor Ravine Mithril loop",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Strong compact route. Mithril supplies Solid Stone, mid-high gems, and rare Truesilver replacements.",
        tips = {
            "Use Badlands when you want compact Mithril rather than a long Tanaris wall loop.",
            "Check cave approaches and ravine rims; many nodes sit on terrain edges.",
            "Clear Mithril to spawn Truesilver replacement opportunities.",
        },
        coords = MITHRIL_BADLANDS,
    },
    thorium = {
        urls = {
            ORE_GUIDE,
            MINING_GUIDE,
            "https://www.wow-professions.com/farming/thorium-ore-farming",
            "https://artisansofazeroth.com/thorium-ore-farming/",
            "https://www.wowhead.com/object=324/small-thorium-vein",
            "https://www.wowhead.com/object=175404/rich-thorium-vein",
        },
        mapName = "Winterspring",
        location = "Winterspring outer mountain-wall Thorium route with Frostsaber, Mazthoril, Everlook, and Darkwhisper checks",
        routeType = "mining-loop",
        density = "High",
        difficulty = "Simple endgame loop. Rich Thorium is the key source for Arcane Crystal and high-end gems.",
        tips = {
            "Follow the outer mountain wall and ridge pockets rather than crossing the open snowfields.",
            "Use Un'Goro or Silithus as backups if the Winterspring loop is heavily contested.",
            "Prioritize Rich Thorium for Arcane Crystal and high-end gem value.",
        },
        coords = THORIUM_WINTERSPRING,
    },
    darkIron = {
        urls = {
            "https://www.wow-professions.com/farming/dark-iron-ore-farming",
            "https://www.wow-professions.com/guides/dark-iron-ore-smelting",
            "https://warcraft.wiki.gg/wiki/Dark_Iron_Deposit",
            "https://www.wowhead.com/item=11370/dark-iron-ore",
        },
        mapName = "Searing Gorge",
        location = "Searing Gorge Dark Iron pockets around the Cauldron, Grimesilt, Dustfire, and Blackrock approaches",
        routeType = "mining-loop",
        density = "Medium",
        difficulty = "Outdoor nodes are scattered; Molten Core and Blackrock Depths are stronger but reset/clear constrained.",
        tips = {
            "Use outdoor Searing Gorge when you want an open-world route with no instance reset pressure.",
            "Use Molten Core or Blackrock Depths when your character can clear safely and you want controlled nodes.",
            "Dark Iron Bars need extra smelting setup, so compare ore versus bar prices.",
        },
        coords = DARK_IRON_SEARING_GORGE,
    },
}

local function RegisterMiningItem(itemID, itemName, professions, category, summary, routeKeys)
    local spots = {}
    local sourceUrls = { ItemUrl(itemID), ORE_GUIDE, MINING_GUIDE }
    for _, routeKey in ipairs(routeKeys) do
        local route = ROUTES[routeKey]
        for _, url in ipairs(route.urls) do
            sourceUrls[#sourceUrls + 1] = url
        end
        spots[#spots + 1] = {
            id = "classic-mining-" .. routeKey .. "-" .. tostring(itemID),
            source = "Wowhead retail object pages, Wowhead mining guides, wow-professions route guides, Artisans of Azeroth route pins, and Classic database notes",
            sourceUrls = route.urls,
            mapName = route.mapName,
            location = route.location,
            routeType = route.routeType,
            density = route.density,
            dropDifficulty = route.difficulty,
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
        category = category,
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    })
end

RegisterMiningItem(2770, "Copper Ore", { "mining" }, "Ore", "Starter ore from low-level rocky zones. Durotar is a dense coordinate-backed route.", { "copper" })
RegisterMiningItem(2771, "Tin Ore", { "mining" }, "Ore", "Low-mid ore from 10-30 zones. Hillsbrad and Alterac foothills have practical Tin density and rare Silver replacement chances.", { "tin" })
RegisterMiningItem(2772, "Iron Ore", { "mining" }, "Ore", "Mid-level ore from Arathi-style ridge routes with Heavy Stone and gem side value.", { "iron" })
RegisterMiningItem(2775, "Silver Ore", { "mining" }, "Ore", "Rare Tin-node replacement. Farm Tin routes and treat Silver as premium turnover value.", { "tin" })
RegisterMiningItem(2776, "Gold Ore", { "mining" }, "Ore", "Rare Iron-node replacement. Farm Iron routes rather than camping old Gold points.", { "iron" })
RegisterMiningItem(3858, "Mithril Ore", { "mining" }, "Ore", "High-mid ore from Badlands-style loops, with Truesilver and valuable gems as side value.", { "mithril" })
RegisterMiningItem(7911, "Truesilver Ore", { "mining" }, "Ore", "Rare Mithril-node replacement. Use compact Mithril loops and maintain node turnover.", { "mithril" })
RegisterMiningItem(10620, "Thorium Ore", { "mining" }, "Ore", "Endgame ore from Small and Rich Thorium nodes. Winterspring has a dense coordinate-backed mountain route.", { "thorium" })
RegisterMiningItem(11370, "Dark Iron Ore", { "mining" }, "Ore", "Specialty Blackrock-area ore. Searing Gorge is the open-world route; BRD/MC are controlled alternatives.", { "darkIron" })

RegisterMiningItem(2835, "Rough Stone", { "mining", "engineering" }, "Stone", "Common side material from Copper nodes; farm dense Copper routes for volume.", { "copper" })
RegisterMiningItem(2836, "Coarse Stone", { "mining", "engineering" }, "Stone", "Common side material from Tin nodes; Barrens Tin loops are the practical route.", { "tin" })
RegisterMiningItem(2838, "Heavy Stone", { "mining", "engineering" }, "Stone", "Side material from Iron nodes; farm Arathi Iron loops.", { "iron" })
RegisterMiningItem(7912, "Solid Stone", { "mining", "engineering" }, "Stone", "Side material from Mithril nodes; Badlands is a compact route.", { "mithril" })
RegisterMiningItem(12365, "Dense Stone", { "mining", "engineering" }, "Stone", "Side material from Thorium nodes; Winterspring, Un'Goro, and Silithus are the main families.", { "thorium" })
