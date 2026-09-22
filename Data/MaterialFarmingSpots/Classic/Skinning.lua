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

local function RegisterSpecialty(itemID, itemName, category, mapName, location, coords, targetUrl, summary, routeType)
    local urls = { ItemUrl(itemID), targetUrl, LEATHER_GUIDE }
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "skinning", "leatherworking" },
        category = category,
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
                id = "classic-specialty-skinning-" .. tostring(itemID),
                source = "Wowhead retail item/NPC pages and specialty-skinning route notes",
                sourceUrls = urls,
                mapName = mapName,
                location = location,
                routeType = routeType or "specialty-skinning-loop",
                density = "Targeted",
                dropDifficulty = "Specialized skin or creature-family drop; expect lower volume than ordinary leather.",
                tips = {
                    "Check the auction value before committing to a long session; these materials sell to recipe collectors and niche crafters.",
                    "Skin every eligible target and keep ordinary leather as steady side value.",
                    "Use a dungeon or raid reset route where listed to avoid outdoor competition.",
                },
                coords = coords,
                confidence = "medium",
            },
        },
    })
end

RegisterSpecialty(6470, "Deviate Scale", "Scale", "Northern Barrens", "Wailing Caverns entrance and Deviate creature circuit", {
    C(0.462, 0.358, "Wailing Caverns entrance"), C(0.478, 0.374, "Caverns outer Deviate creatures"),
}, "https://www.wowhead.com/zone=718/wailing-caverns", "A distinctive low-level scale used by Deviate leatherworking patterns.", "dungeon-skinning")
RegisterSpecialty(6471, "Perfect Deviate Scale", "Scale", "Northern Barrens", "Wailing Caverns Deviate creature clears", {
    C(0.462, 0.358, "Wailing Caverns entrance"), C(0.478, 0.374, "Caverns outer Deviate creatures"),
}, "https://www.wowhead.com/zone=718/wailing-caverns", "The rarer Deviate scale used by collectible leatherworking crafts.", "dungeon-skinning")
RegisterSpecialty(8154, "Scorpid Scale", "Scale", "Tanaris", "Scorpid circuit around Gadgetzan and the eastern desert", {
    C(0.522, 0.342, "Gadgetzan east scorpids"), C(0.612, 0.420, "Noonshade scorpids"), C(0.646, 0.566, "East desert scorpids"),
}, "https://www.wowhead.com/npc=5422/scorpid-hunter", "Mid-level scorpid scale used by leatherworking armor patterns.")
RegisterSpecialty(8165, "Worn Dragonscale", "Dragonscale", "Swamp of Sorrows", "Dragonkin loop through the eastern swamp", {
    C(0.700, 0.238, "Misty Valley dragonkin"), C(0.760, 0.330, "Eastern swamp dragonkin"), C(0.814, 0.482, "Stagalbog dragonkin edge"),
}, "https://www.wowhead.com/npc=740/teenage-nether-drake", "Lower-tier dragonscale side yield from skinnable dragonkin.")
RegisterSpecialty(8167, "Turtle Scale", "Scale", "The Hinterlands", "Saltwater Snapjaw shoreline loop", {
    C(0.704, 0.620, "Overlook Cliffs turtles"), C(0.780, 0.650, "Eastern shore turtles"), C(0.824, 0.568, "Revantusk shore turtles"),
}, "https://www.wowhead.com/npc=2505/saltwater-snapjaw", "Turtle-family skin used by several distinctive leatherworking recipes.")
RegisterSpecialty(15408, "Heavy Scorpid Scale", "Scale", "Blasted Lands", "Scorpid and scorpion circuit across the central badlands", {
    C(0.436, 0.340, "Central scorpid field"), C(0.520, 0.382, "Dreadmaul scorpid edge"), C(0.604, 0.464, "East scorpid route"),
}, "https://www.wowhead.com/npc=5988/scorpok-stinger", "Endgame scorpid scale for specialty mail leatherworking crafts.")
RegisterSpecialty(15412, "Green Dragonscale", "Dragonscale", "Feralas", "Dream Bough green dragonkin perimeter", {
    C(0.500, 0.104, "Dream Bough west dragonkin"), C(0.520, 0.118, "Dream Bough center"), C(0.548, 0.104, "Dream Bough east dragonkin"),
}, "https://www.wowhead.com/npc=5356/snapping-dragon", "Color-specific dragonscale for old Dragonscale Leatherworking crafts.")
RegisterSpecialty(15414, "Red Dragonscale", "Dragonscale", "Wetlands", "Dragonmaw and red whelp route in the eastern Wetlands", {
    C(0.646, 0.442, "Dragonmaw red whelps"), C(0.684, 0.474, "Greenwarden dragonkin edge"), C(0.724, 0.520, "Eastern Wetlands whelps"),
}, "https://www.wowhead.com/npc=1044/flamesnorting-whelp", "Rare color-specific dragonscale from red dragonkin.")
RegisterSpecialty(15415, "Blue Dragonscale", "Dragonscale", "Winterspring", "Mazthoril blue dragonkin circuit", {
    C(0.552, 0.486, "Mazthoril entrance"), C(0.574, 0.522, "Mazthoril dragonkin"), C(0.606, 0.548, "Mazthoril outer loop"),
}, "https://www.wowhead.com/npc=7435/cobalt-wyrmkin", "Blue dragonscale used by resistance and collectible leatherworking recipes.")
RegisterSpecialty(15416, "Black Dragonscale", "Dragonscale", "Burning Steppes", "Black dragonkin route around the Slither Rock and Terror Wing paths", {
    C(0.776, 0.520, "Terror Wing path"), C(0.844, 0.566, "Black dragonkin ridge"), C(0.902, 0.584, "Eastern drake loop"),
}, "https://www.wowhead.com/npc=7040/black-dragonspawn", "Black dragonscale for high-end Classic mail patterns.")
RegisterSpecialty(15417, "Devilsaur Leather", "Specialty Leather", "Un'Goro Crater", "Full crater circuit following Devilsaur patrol paths", {
    C(0.302, 0.292, "Northwest Devilsaur patrol"), C(0.574, 0.254, "North ridge patrol"), C(0.706, 0.514, "East crater patrol"), C(0.518, 0.760, "South crater patrol"), C(0.284, 0.598, "West crater patrol"),
}, "https://www.wowhead.com/npc=6498/devilsaur", "Iconic specialty leather with renewed Midnight housing demand.")
RegisterSpecialty(15419, "Warbear Leather", "Specialty Leather", "Winterspring", "Shardtooth bear route around Everlook and Frostsaber Rock", {
    C(0.542, 0.410, "Everlook north bears"), C(0.494, 0.274, "Frostsaber Rock bears"), C(0.616, 0.420, "East Winterspring bears"),
}, "https://www.wowhead.com/npc=7443/shardtooth-mauler", "Bear-specific leather used by Warbear collectible crafts.")
RegisterSpecialty(15422, "Frostsaber Leather", "Specialty Leather", "Winterspring", "Frostsaber Rock cat circuit", {
    C(0.482, 0.160, "Frostsaber Rock west"), C(0.512, 0.182, "Frostsaber Rock center"), C(0.538, 0.224, "Frostsaber Rock south"),
}, "https://www.wowhead.com/npc=7430/frostsaber-cub", "Winterspring cat leather used in specialty leatherworking patterns.")
RegisterSpecialty(15423, "Chimera Leather", "Specialty Leather", "Winterspring", "Chimaera circuit north and east of Everlook", {
    C(0.586, 0.282, "North Everlook chimaera"), C(0.620, 0.314, "Ice Thistle east chimaera"), C(0.650, 0.362, "Eastern chimaera return"),
}, "https://www.wowhead.com/npc=7448/chillwind-chimaera", "Creature-specific leather from Winterspring chimaera.")
RegisterSpecialty(17012, "Core Leather", "Raid Leather", "Burning Steppes", "Molten Core clears with skinnable Core Hounds", {
    C(0.210, 0.382, "Blackrock Mountain entrance"), C(0.270, 0.240, "Molten Core raid entrance area"),
}, "https://www.wowhead.com/zone=2717/molten-core", "Raid-gated leather skinned from Core Hounds in Molten Core.", "raid-skinning")
RegisterSpecialty(19767, "Primal Bat Leather", "Specialty Leather", "Northern Stranglethorn", "Zul'Gurub bat packs and bosses", {
    C(0.722, 0.326, "Zul'Gurub entrance"), C(0.696, 0.302, "Zul'Gurub approach"),
}, "https://www.wowhead.com/zone=1977/zulgurub", "Zul'Gurub specialty leather from skinnable bats.", "raid-skinning")
RegisterSpecialty(19768, "Primal Tiger Leather", "Specialty Leather", "Northern Stranglethorn", "Zul'Gurub tiger packs and bosses", {
    C(0.722, 0.326, "Zul'Gurub entrance"), C(0.696, 0.302, "Zul'Gurub approach"),
}, "https://www.wowhead.com/zone=1977/zulgurub", "Zul'Gurub specialty leather from skinnable tigers.", "raid-skinning")
RegisterSpecialty(20381, "Dreamscale", "Dragonscale", "Swamp of Sorrows", "Sunken Temple green dragon and dragonkin clears", {
    C(0.692, 0.540, "Sunken Temple entrance"),
    C(0.704, 0.548, "Temple approach and reset anchor"),
}, "https://www.wowhead.com/zone=1477/the-temple-of-atalhakkar", "Very rare skinning yield from green dragon creatures in Sunken Temple, reintroduced in patch 10.1.5. Anniversary Dragons of Nightmare are an event-only bonus source.", "dungeon-skinning")
