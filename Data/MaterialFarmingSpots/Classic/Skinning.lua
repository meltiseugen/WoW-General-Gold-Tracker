local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local LEATHER_GUIDE = "https://www.wowhead.com/guide/classic-leather-farming-early-leather"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function LeatherUrl(slug)
    return "https://www.wow-professions.com/farming/" .. slug .. "-farming"
end

local ROUTES = {
    scraps = {
        urls = { LEATHER_GUIDE, ItemUrl(2934), "https://www.wowhead.com/npc=113/wolf" },
        mapName = "Elwynn Forest",
        location = "Northshire and Goldshire wolf/boar route for starter scraps",
        density = "High",
        difficulty = "Easy. Scraps come from very low-level skins and are mostly a starter byproduct.",
        tips = {
            "Skin every eligible wolf and boar while moving between starter camps.",
            "This is a starter route; move to Light Leather once scraps stop being the main result.",
            "Use abandoned quest corpses when other players are killing but not skinning.",
        },
        coords = {
            C(0.444, 0.706, "Northshire wolf and boar field"),
            C(0.488, 0.812, "Echo Ridge starter beasts"),
            C(0.422, 0.654, "Goldshire north boars"),
            C(0.344, 0.580, "Fargodeep Mine exterior beasts"),
        },
    },
    light = {
        urls = { LEATHER_GUIDE, LeatherUrl("light-leather"), ItemUrl(2318), ItemUrl(783), "https://www.wowhead.com/npc=1196/ice-claw-bear", "https://www.wowhead.com/item=783/light-hide" },
        mapName = "Loch Modan",
        location = "Loch Modan bear, boar, wolf, and crocolisk loops around Thelsamar and the loch",
        density = "High",
        difficulty = "Easy. Light Leather is common from early skinnable beasts.",
        tips = {
            "Loch Modan has compact beast paths and is easy to run repeatedly.",
            "Skin abandoned quest mobs if other players are clearing the same area.",
            "Add Copper/Tin and low herbs if you want a mixed gathering pass.",
        },
        coords = {
            C(0.346, 0.292, "Silver Stream Mine exterior beasts"),
            C(0.360, 0.468, "Thelsamar west bears"),
            C(0.506, 0.418, "Loch shore crocolisks"),
            C(0.580, 0.544, "Stonewrought Dam beast edge"),
            C(0.704, 0.638, "Mo'grosh area beasts"),
        },
    },
    medium = {
        urls = { LEATHER_GUIDE, LeatherUrl("medium-leather"), ItemUrl(2319), ItemUrl(4232), "https://www.wowhead.com/npc=42043/ebon-slavehunter", "https://www.wowhead.com/item=4232/medium-hide" },
        mapName = "Wetlands",
        location = "Wetlands Ebon Slavehunter fast-respawn skinnable camp east of Greenwarden's Grove",
        density = "High and localized",
        difficulty = "Very good. Ebon Slavehunters are skinnable, fight nearby Dragonmaw mobs, and respawn quickly.",
        tips = {
            "Stay around the Greenwarden camp and skin every Ebon Slavehunter corpse as it respawns.",
            "Use the nearby wetlands route only if the fast-spawn camp is occupied.",
            "This camp can produce Light Leather, Medium Leather, Ruined Scraps, Light Hide, and Medium Hide from the same skinning table.",
        },
        coords = {
            C(0.670, 0.470, "Greenwarden road corpse cluster"),
            C(0.680, 0.472, "Ebon Slavehunter fast-respawn pin"),
            C(0.690, 0.474, "Dragonmaw skirmish line"),
            C(0.674, 0.486, "South camp corpse pile"),
            C(0.686, 0.458, "North camp respawn check"),
        },
    },
    heavy = {
        urls = { LEATHER_GUIDE, LeatherUrl("heavy-leather"), LeatherUrl("heavy-hide"), ItemUrl(4234), ItemUrl(4235), "https://www.wowhead.com/npc=39896/feral-scar-yeti", "https://www.wowhead.com/npc=40224/rage-scar-yeti", "https://www.wowhead.com/item=4235/heavy-hide" },
        mapName = "Arathi Highlands",
        location = "Arathi raptor and beast route around the highland fields and Stromgarde outskirts",
        density = "High",
        difficulty = "Good but traffic-dependent. Arathi is less chaotic than many Stranglethorn camps.",
        tips = {
            "Use Arathi raptors as the compact route; add Stranglethorn only if you want more mixed beast options.",
            "The same zone supports Iron, Kingsblood, Goldthorn, and elemental side farms.",
            "Heavy Hides can appear as side value on the same skins.",
        },
        coords = {
            C(0.354, 0.314, "Northfold raptor edge"),
            C(0.486, 0.414, "Central highlands beasts"),
            C(0.590, 0.548, "Dabyrie's Farmstead raptors"),
            C(0.680, 0.398, "Hammerfall south raptors"),
            C(0.296, 0.720, "Stromgarde outer raptors"),
        },
    },
    thick = {
        urls = { LEATHER_GUIDE, LeatherUrl("thick-leather"), LeatherUrl("thick-hide"), ItemUrl(4304), ItemUrl(8169), "https://www.wowhead.com/npc=5291/hakkari-frostwing", "https://www.wowhead.com/item=8169/thick-hide" },
        mapName = "Feralas",
        location = "Feralas yeti, wolf, bear, and hippogryph route around High Wilderness and Feral Scar",
        density = "Medium to high",
        difficulty = "Good. Thick Leather overlaps with Rugged Leather as mob levels rise.",
        tips = {
            "Use Feralas when you want leather, Mageweave, herbs, and Mithril side value together.",
            "Favor dense beast pockets instead of chasing isolated wildlife.",
            "If Thick turns into too much Rugged, shift toward lower-level Feralas pockets.",
        },
        coords = {
            C(0.530, 0.560, "Feral Scar beast route"),
            C(0.570, 0.518, "High Wilderness beasts"),
            C(0.642, 0.540, "Gordunni edge beasts"),
            C(0.708, 0.558, "Lower Wilds beast path"),
            C(0.754, 0.626, "Southeast Feralas beast route"),
        },
    },
    rugged = {
        urls = { LEATHER_GUIDE, LeatherUrl("rugged-leather"), LeatherUrl("rugged-hide"), ItemUrl(8170), ItemUrl(8171), "https://www.wowhead.com/npc=9166/pterrordax", "https://www.wowhead.com/item=8171/rugged-hide" },
        mapName = "Un'Goro Crater",
        location = "Un'Goro dinosaur and pterrordax crater circuit for Rugged Leather",
        density = "High",
        difficulty = "Moderate. Endgame beasts are efficient but can include knockbacks and dense aggro.",
        tips = {
            "Circle the crater and skin every dinosaur, pterrordax, and high-level beast you kill.",
            "Pair the route with Thorium and endgame herbs.",
            "Use Winterspring bears/chimaera if Un'Goro is crowded.",
        },
        coords = {
            C(0.326, 0.266, "Northwest dinosaur route"),
            C(0.496, 0.260, "Northern pterrordax route"),
            C(0.660, 0.404, "Eastern dinosaur route"),
            C(0.606, 0.642, "Southeast raptor route"),
            C(0.426, 0.802, "Southern crater beasts"),
            C(0.286, 0.600, "Slithering Scar beast edge"),
        },
    },
}

local function RegisterLeather(itemID, itemName, category, routeKey, summary)
    local route = ROUTES[routeKey]
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "skinning", "leatherworking" },
        category = category,
        researchStatus = "researched",
        sourceUrls = route.urls,
        summary = summary,
        spots = {
            {
                id = "classic-skinning-" .. routeKey .. "-" .. tostring(itemID),
                source = "Wowhead retail leather item/NPC pages, wow-professions farming guides, Wowhead NPC map pins, and skinning comments",
                sourceUrls = route.urls,
                mapName = route.mapName,
                location = route.location,
                routeType = "skinning-loop",
                density = route.density,
                dropDifficulty = route.difficulty,
                tips = route.tips,
                coords = route.coords,
                confidence = "high",
            },
        },
    })
end

RegisterLeather(2934, "Ruined Leather Scraps", "Scrap", "scraps", "Starter skinning scraps from very low-level beasts.")
RegisterLeather(2318, "Light Leather", "Leather", "light", "Early Classic leather from low-level skinnable beasts and scrap conversion.")
RegisterLeather(2319, "Medium Leather", "Leather", "medium", "Mid-low Classic leather from level 20-30 beasts and conversion.")
RegisterLeather(4234, "Heavy Leather", "Leather", "heavy", "Mid-level Classic leather from Arathi, Stranglethorn, and Dustwallow beast routes.")
RegisterLeather(4304, "Thick Leather", "Leather", "thick", "High-level Classic leather from Feralas, Hinterlands, and Un'Goro routes.")
RegisterLeather(8170, "Rugged Leather", "Leather", "rugged", "Endgame Classic leather from Un'Goro, Winterspring, and Eastern Plaguelands beasts.")
RegisterLeather(783, "Light Hide", "Hide", "light", "Low-level Classic hide side yield from Light Leather skinning routes.")
RegisterLeather(4232, "Medium Hide", "Hide", "medium", "Mid-low hide side yield from the Wetlands Ebon Slavehunter skinning table.")
RegisterLeather(4235, "Heavy Hide", "Hide", "heavy", "Mid-level hide side yield from Heavy Leather routes; Feralas yetis and swamp dragonkin are practical targets.")
RegisterLeather(8169, "Thick Hide", "Hide", "thick", "High-level hide side yield from Thick Leather beast routes.")
RegisterLeather(8171, "Rugged Hide", "Hide", "rugged", "Endgame hide side yield from Rugged Leather beast routes.")
