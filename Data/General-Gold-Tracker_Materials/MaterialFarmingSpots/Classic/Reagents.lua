local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local ROUTES = {
    badlandsEarth = { mapName = "Badlands", location = "Southwestern rock elemental circuit", targetUrl = "https://www.wowhead.com/npc=2736/greater-rock-elemental", coords = { C(0.152, 0.726, "Southwest rock elementals"), C(0.184, 0.742, "Central elemental field"), C(0.222, 0.774, "East elemental return") } },
    searingFire = { mapName = "Searing Gorge", location = "Cauldron and Dustfire Valley fire elemental loop", targetUrl = "https://www.wowhead.com/npc=5852/inferno-elemental", coords = { C(0.420, 0.342, "Cauldron fire elementals"), C(0.508, 0.434, "Inner Cauldron route"), C(0.674, 0.554, "Dustfire Valley") } },
    felwoodWater = { mapName = "Felwood", location = "Toxic Horrors around Irontree Woods and Bloodvenom Falls", targetUrl = "https://www.wowhead.com/npc=7132/toxic-horror", coords = { C(0.468, 0.160, "Irontree Toxic Horrors"), C(0.406, 0.348, "Bloodvenom north"), C(0.420, 0.408, "Bloodvenom Falls") } },
    silithusAir = { mapName = "Silithus", location = "Dust Stormer loop in northwest Silithus", targetUrl = "https://www.wowhead.com/npc=11744/dust-stormer", coords = { C(0.220, 0.128, "Northwest Dust Stormer"), C(0.248, 0.154, "Central stormer field"), C(0.278, 0.184, "East stormer field") } },
    plaguelandsUndead = { mapName = "Eastern Plaguelands", location = "Corin's Crossing, Plaguewood, and Stratholme undead route", targetUrl = "https://www.wowhead.com/zone=2017/stratholme", coords = { C(0.344, 0.456, "Corin's Crossing"), C(0.220, 0.248, "Plaguewood"), C(0.272, 0.116, "Stratholme entrance") } },
    moltenCore = { mapName = "Burning Steppes", location = "Molten Core raid clears", targetUrl = "https://www.wowhead.com/zone=2717/molten-core", coords = { C(0.210, 0.382, "Blackrock Mountain entrance"), C(0.270, 0.240, "Molten Core entrance area") } },
    ungoroStone = { mapName = "Un'Goro Crater", location = "Stone Guardian checks around the crater pylons", targetUrl = "https://www.wowhead.com/npc=6560/stone-guardian", coords = { C(0.238, 0.584, "West pylon guardian"), C(0.562, 0.126, "North pylon guardian"), C(0.770, 0.492, "East pylon guardian") } },
    scholomance = { mapName = "Western Plaguelands", location = "Scholomance entrance and repeatable dungeon clears", targetUrl = "https://www.wowhead.com/zone=2057/scholomance", coords = { C(0.694, 0.734, "Scholomance entrance"), C(0.488, 0.788, "Sorrow Hill route") } },
}

local function RegisterReagent(itemID, itemName, professions, category, routeKey, summary, routeType)
    local route = ROUTES[routeKey]
    local urls = { ItemUrl(itemID), route.targetUrl }
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = professions,
        category = category,
        isRoute = false,
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
                isRoute = false,
                id = "classic-reagent-" .. tostring(itemID),
                source = "Wowhead retail item/NPC/zone pages and material farming route notes",
                sourceUrls = urls,
                mapName = route.mapName,
                location = route.location,
                routeType = routeType or "creature-reagent-grind",
                density = "Targeted",
                dropDifficulty = "Specialized or uncommon drop; use a full circuit and value the route's side drops.",
                tips = {
                    "These niche reagents can sell slowly, so list in recipe-sized stacks.",
                    "Check appearances before vendoring or disenchanting uncommon gear from the route.",
                    "Switch routes when competition makes the target density poor.",
                },
                coords = route.coords,
                confidence = "medium",
            },
        },
    })
end

RegisterReagent(7075, "Core of Earth", { "alchemy", "blacksmithing", "engineering" }, "Elemental", "badlandsEarth", "Solid earth-elemental reagent from rock elementals.")
RegisterReagent(7077, "Heart of Fire", { "alchemy", "blacksmithing", "engineering" }, "Elemental", "searingFire", "Fire-elemental reagent from fire creatures.")
RegisterReagent(7079, "Globe of Water", { "alchemy", "tailoring", "engineering" }, "Elemental", "felwoodWater", "Water-elemental reagent from water creatures.")
RegisterReagent(7081, "Breath of Wind", { "alchemy", "leatherworking", "engineering" }, "Elemental", "silithusAir", "Air-elemental reagent from wind creatures.")
RegisterReagent(7972, "Ichor of Undeath", { "alchemy", "tailoring", "enchanting" }, "Reagent", "plaguelandsUndead", "Undead reagent from high-level undead routes.")
RegisterReagent(11382, "Blood of the Mountain", { "blacksmithing", "engineering" }, "Rare Reagent", "moltenCore", "Rare Molten Core and Dark Iron reagent with niche craft demand.", "raid-trash-farm")
RegisterReagent(12809, "Guardian Stone", { "blacksmithing", "enchanting" }, "Rare Reagent", "ungoroStone", "Rare stone reagent from Un'Goro Stone Guardians.")
RegisterReagent(12811, "Righteous Orb", { "tailoring", "enchanting" }, "Rare Reagent", "plaguelandsUndead", "Premium Stratholme/Scarlet reagent used by legacy enchants and crafts.", "dungeon-trash-farm")
RegisterReagent(17010, "Fiery Core", { "blacksmithing", "enchanting", "engineering" }, "Raid Reagent", "moltenCore", "Molten Core reagent now also consumed by Classic Midnight decor.", "raid-trash-farm")
RegisterReagent(17011, "Lava Core", { "blacksmithing", "enchanting", "engineering" }, "Raid Reagent", "moltenCore", "Molten Core reagent now also consumed by Classic Midnight decor.", "raid-trash-farm")
RegisterReagent(20520, "Dark Rune", { "alchemy", "enchanting", "inscription" }, "Rare Reagent", "scholomance", "Scholomance rune with consumable and Midnight housing demand.", "dungeon-trash-farm")
