local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local ELEMENTAL_INDEX = "https://www.wow-professions.com/farming/elementals"
local INVASION_GUIDE = "https://www.wowhead.com/guide/elemental-invasions-wow-classic"
local INVASION_NEWS = "https://www.wowhead.com/news/elemental-invasions-good-way-to-farm-essences-in-wow-classic-299464"

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function FarmUrl(slug)
    return "https://www.wow-professions.com/farming/" .. slug .. "-farming"
end

local ROUTES = {
    elementalEarth = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("elemental-earth"),
            ItemUrl(7067),
            "https://www.wowhead.com/npc=2736/greater-rock-elemental",
        },
        mapName = "Badlands",
        location = "Greater Rock Elementals in the southwest Badlands rock camps",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Moderate. Earth elementals are close enough for a small loop but can be contested.",
        tips = {
            "Loop the southwestern rock elemental pockets rather than waiting on one cluster.",
            "Elemental Earth is the common goal here; Essence of Earth can be better in higher-level Silithus.",
            "Skinning/mining side routes in Badlands can fill respawn downtime.",
        },
        coords = {
            C(0.152, 0.726, "Southwest Greater Rock Elemental"),
            C(0.184, 0.742, "Central Greater Rock Elemental"),
            C(0.222, 0.774, "Eastern Greater Rock Elemental"),
            C(0.248, 0.708, "Dustbowl rock elemental edge"),
        },
    },
    elementalFire = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("elemental-fire"),
            ItemUrl(7068),
            "https://www.wowhead.com/npc=5852/inferno-elemental",
        },
        mapName = "Searing Gorge",
        location = "Fire elemental pockets around the Cauldron and Dustfire Valley",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Easy to moderate. Outdoor fire mobs are spread but simple to repeat.",
        tips = {
            "Use Searing Gorge for Elemental Fire when Un'Goro Essence routes are too contested.",
            "Sweep the Cauldron rim and Dustfire Valley instead of camping one spawn point.",
            "Nearby Dark Iron and Thorium checks can add value.",
        },
        coords = {
            C(0.420, 0.342, "Cauldron northwest fire elementals"),
            C(0.508, 0.434, "Cauldron inner fire route"),
            C(0.610, 0.382, "Grimesilt/Dustfire approach"),
            C(0.674, 0.554, "Dustfire Valley fire elementals"),
        },
    },
    elementalAir = {
        urls = {
            ELEMENTAL_INDEX,
            ItemUrl(7069),
            "https://www.wowhead.com/npc=2592/rumbling-exile",
            "https://www.wowhead.com/npc=2595/thundering-exile",
        },
        mapName = "Arathi Highlands",
        location = "Circle of East Binding and nearby elemental exile camps",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Moderate. Elemental Air is a lower-tier side result from exile-style elemental routes.",
        tips = {
            "Use Arathi elemental circles for lower-tier elemental materials while also gathering herbs and ore.",
            "Move between elemental circles if respawns are slow.",
            "For Essence of Air specifically, use Silithus Dust Stormers instead.",
        },
        coords = {
            C(0.522, 0.502, "Circle of East Binding"),
            C(0.548, 0.500, "Eastern elemental circle edge"),
            C(0.598, 0.316, "Circle of Outer Binding"),
            C(0.618, 0.346, "Outer Binding elemental edge"),
        },
    },
    elementalWater = {
        urls = {
            ELEMENTAL_INDEX,
            ItemUrl(7070),
            "https://www.wowhead.com/npc=691/lesser-water-elemental",
        },
        mapName = "Stranglethorn Vale",
        location = "Water elemental island and shoreline route off northwest Stranglethorn",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Moderate. Water mobs are localized and travel can slow the route.",
        tips = {
            "Use water walking, swim speed, or a flying-capable retail character to reduce travel friction.",
            "If the island is empty, switch to Essence of Water routes rather than waiting.",
            "Watch auction value against Stranglekelp or fishing routes nearby.",
        },
        coords = {
            C(0.204, 0.220, "Water elemental island north"),
            C(0.226, 0.242, "Water elemental island center"),
            C(0.246, 0.274, "Water elemental island south"),
            C(0.284, 0.246, "Mainland shoreline water checks"),
        },
    },
    essenceEarth = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("essence-of-earth"),
            INVASION_GUIDE,
            INVASION_NEWS,
            ItemUrl(7076),
            "https://www.wowhead.com/npc=11746/desert-rumbler",
        },
        mapName = "Silithus",
        location = "Northwest Silithus Desert Rumbler and earth elemental route",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Moderate to hard. Drop rate is streaky and competition matters.",
        tips = {
            "Use the northwest elemental fields around 23,14 to 26,20 as the focused route.",
            "Comments report long dry streaks; track time and value against other elemental farms.",
            "Mine Thorium/Mithril side nodes while moving between elemental pockets.",
        },
        coords = {
            C(0.230, 0.140, "Northwest Desert Rumbler camp"),
            C(0.246, 0.178, "Central Desert Rumbler field"),
            C(0.270, 0.210, "East Desert Rumbler field"),
            C(0.214, 0.218, "Southwest elemental edge"),
        },
    },
    essenceFire = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("essence-of-fire"),
            INVASION_GUIDE,
            INVASION_NEWS,
            ItemUrl(7078),
            "https://www.wowhead.com/npc=6520/scorching-elemental",
            "https://www.wowhead.com/npc=6521/living-blaze",
        },
        mapName = "Un'Goro Crater",
        location = "Fire Plume Ridge Scorching Elemental and Living Blaze route",
        routeType = "elemental-grind",
        density = "High",
        difficulty = "Good open-world targeted fire farm; central terrain and mobs can slow low-level characters.",
        tips = {
            "Circle Fire Plume Ridge and pull every fire elemental on the volcano slopes.",
            "Molten Core is stronger for geared characters, but this route is always open-world available.",
            "Add Thorium and high herb checks around the crater wall after each volcano pass.",
        },
        coords = {
            C(0.474, 0.424, "Fire Plume west slope"),
            C(0.506, 0.458, "Fire Plume summit route"),
            C(0.534, 0.500, "Fire Plume east slope"),
            C(0.490, 0.542, "Fire Plume south slope"),
            C(0.444, 0.494, "Fire Plume lower west"),
        },
    },
    essenceAir = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("essence-of-air"),
            INVASION_GUIDE,
            INVASION_NEWS,
            ItemUrl(7082),
            "https://www.wowhead.com/npc=11744/dust-stormer",
        },
        mapName = "Silithus",
        location = "Northwest Silithus Dust Stormer route",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Hard. Dust Stormer drop rates are low and respawns are spread out.",
        tips = {
            "Use the same northwest Silithus route repeatedly and pull Dust Stormers first.",
            "Comments disagree on yield, so treat this as a high-variance farm.",
            "Elemental Earth and Thorium side value help smooth bad Essence of Air streaks.",
        },
        coords = {
            C(0.220, 0.128, "Northwest Dust Stormer"),
            C(0.248, 0.154, "Central Dust Stormer field"),
            C(0.278, 0.184, "East Dust Stormer field"),
            C(0.238, 0.228, "Southwest Dust Stormer edge"),
        },
    },
    essenceWater = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("essence-of-water"),
            INVASION_GUIDE,
            INVASION_NEWS,
            ItemUrl(7080),
            "https://www.wowhead.com/npc=7132/toxic-horror",
        },
        mapName = "Felwood",
        location = "Toxic Horror route around Irontree Woods and Bloodvenom Falls",
        routeType = "elemental-grind",
        density = "Medium",
        difficulty = "Moderate. Toxic Horrors are a focused outdoor farm but can be thin after competition.",
        tips = {
            "Use Felwood Toxic Horrors for a mapped outdoor farm; Lake Kel'Theril is another viable route.",
            "Pair the route with Gromsblood, Dreamfoil, and Felcloth checks.",
            "Expect Essence of Water to be the premium result and Elemental Water as side value.",
        },
        coords = {
            C(0.468, 0.160, "Irontree Woods Toxic Horror"),
            C(0.494, 0.210, "Irontree eastern Toxic Horror"),
            C(0.406, 0.348, "Bloodvenom north water route"),
            C(0.420, 0.408, "Bloodvenom Falls water route"),
        },
    },
    living = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("living-essence"),
            ItemUrl(12803),
            "https://www.wowhead.com/npc=7139/irontree-stomper",
            "https://www.wowhead.com/npc=6556/muculent-ooze",
        },
        mapName = "Felwood",
        location = "Irontree Woods treant route with nearby ooze and nature-mob checks",
        routeType = "nature-mob-grind",
        density = "Medium",
        difficulty = "Moderate. Living Essence is uncommon and usually a premium side drop.",
        tips = {
            "Loop Irontree Woods treants and nature mobs, then add Bloodvenom/Jadefire side routes if respawns are slow.",
            "Compare Living Essence value against herbs and Felcloth from the same zone.",
            "Dire Maul plant-heavy clears are useful if you prefer instance control.",
        },
        coords = {
            C(0.474, 0.144, "Irontree Woods north treants"),
            C(0.494, 0.190, "Irontree central treants"),
            C(0.524, 0.246, "Irontree south treants"),
            C(0.430, 0.356, "Bloodvenom nature mobs"),
        },
    },
    undeath = {
        urls = {
            ELEMENTAL_INDEX,
            FarmUrl("essence-of-undeath"),
            ItemUrl(12808),
            "https://www.wowhead.com/npc=8523/scourge-soldier",
            "https://www.wowhead.com/zone=2017/stratholme",
        },
        mapName = "Western Plaguelands",
        location = "Sorrow Hill and Andorhal undead route for Essence of Undeath and Runecloth side value",
        routeType = "undead-grind",
        density = "High",
        difficulty = "Good. Undead routes also produce Runecloth and Argent Dawn side value.",
        tips = {
            "Use Sorrow Hill and Andorhal open-world undead when you want a mapped route.",
            "Switch to Stratholme or Scholomance clears for repeatable dungeon density.",
            "Equip Argent Dawn reputation tools in Classic contexts when useful.",
        },
        coords = {
            C(0.488, 0.788, "Sorrow Hill west undead"),
            C(0.518, 0.822, "Sorrow Hill east undead"),
            C(0.438, 0.694, "Andorhal south undead"),
            C(0.472, 0.620, "Andorhal central undead"),
            C(0.396, 0.548, "Andorhal north undead"),
        },
    },
}

local function RegisterElemental(itemID, itemName, professions, category, routeKey, summary)
    local route = ROUTES[routeKey]
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = professions,
        category = category,
        researchStatus = "researched",
        sourceUrls = route.urls,
        summary = summary,
        spots = {
            {
                id = "classic-elemental-" .. routeKey .. "-" .. tostring(itemID),
                source = "Wowhead item/NPC pages, Wowhead comments, wow-professions elemental guides, and Classic database drop tables",
                sourceUrls = route.urls,
                mapName = route.mapName,
                location = route.location,
                routeType = route.routeType,
                density = route.density,
                dropDifficulty = route.difficulty,
                tips = route.tips,
                coords = route.coords,
                confidence = "high",
            },
        },
    })
end

RegisterElemental(7067, "Elemental Earth", { "alchemy", "engineering", "blacksmithing" }, "Elemental", "elementalEarth", "Lower-tier earth elemental material from rock/earth elemental camps.")
RegisterElemental(7068, "Elemental Fire", { "alchemy", "engineering", "blacksmithing" }, "Elemental", "elementalFire", "Lower-tier fire elemental material from fire elemental routes and invasions.")
RegisterElemental(7069, "Elemental Air", { "alchemy", "engineering" }, "Elemental", "elementalAir", "Lower-tier air elemental material from Arathi elemental routes.")
RegisterElemental(7070, "Elemental Water", { "alchemy", "engineering" }, "Elemental", "elementalWater", "Lower-tier water elemental material from localized water elemental routes.")
RegisterElemental(7076, "Essence of Earth", { "alchemy", "blacksmithing", "engineering" }, "Essence", "essenceEarth", "High-tier earth essence from earth elementals and Azshara/Silithus-style elemental farms.")
RegisterElemental(7078, "Essence of Fire", { "alchemy", "blacksmithing", "engineering" }, "Essence", "essenceFire", "High-tier fire essence. Fire Plume Ridge is the mapped open-world farm; Molten Core is stronger when clearable.")
RegisterElemental(7080, "Essence of Water", { "alchemy", "tailoring", "engineering" }, "Essence", "essenceWater", "High-tier water essence from Felwood Toxic Horrors, Lake Kel'Theril, and invasion spawns.")
RegisterElemental(7082, "Essence of Air", { "alchemy", "leatherworking", "engineering" }, "Essence", "essenceAir", "High-tier air essence from Silithus Dust Stormers and invasion spawns. Expect low drop rates.")
RegisterElemental(12803, "Living Essence", { "alchemy", "leatherworking" }, "Essence", "living", "Nature essence from treant, tar, ooze, and plant-style farms.")
RegisterElemental(12808, "Essence of Undeath", { "alchemy", "tailoring", "enchanting" }, "Essence", "undeath", "Undead essence from high-level Plaguelands camps and undead-heavy dungeon clears.")
