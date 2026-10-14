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
    wetlandsMurloc = { mapName = "Wetlands", location = "Bluegill Marsh murloc coast north of Menethil Harbor", targetUrl = "https://www.wowhead.com/item=5785/thick-murloc-scale", coords = { C(0.136, 0.426, "Bluegill Marsh south"), C(0.160, 0.360, "Bluegill Marsh center"), C(0.182, 0.282, "Sundown Marsh return") } },
    feralasFeather = { mapName = "Feralas", location = "Vale Screecher and hippogryph circuit through central Feralas", targetUrl = "https://www.wowhead.com/npc=5307/vale-screecher", coords = { C(0.552, 0.502, "Central hippogryphs"), C(0.602, 0.520, "High Wilderness edge"), C(0.660, 0.556, "Lower Wilds return") } },
    wetlandsVenom = { mapName = "Wetlands", location = "Spider and crocolisk circuit around Greenwarden's Grove", targetUrl = "https://www.wowhead.com/npc=1111/leech-stalker", coords = { C(0.520, 0.380, "Greenwarden west spiders"), C(0.590, 0.430, "Central spider pocket"), C(0.650, 0.490, "East Wetlands spiders") } },
    dustwallowSpider = { mapName = "Dustwallow Marsh", location = "Darkmist spider circuit west of Brackenwall", targetUrl = "https://www.wowhead.com/npc=4377/darkmist-lurker", coords = { C(0.330, 0.220, "Darkmist north"), C(0.350, 0.260, "Darkmist center"), C(0.380, 0.300, "Darkmist south") } },
    hinterlandsTroll = { mapName = "The Hinterlands", location = "Vilebranch and Jintha'Alor troll circuit", targetUrl = "https://www.wowhead.com/npc=2642/vilebranch-shadowcaster", coords = { C(0.624, 0.690, "Jintha'Alor lower"), C(0.662, 0.730, "Jintha'Alor center"), C(0.704, 0.760, "Jintha'Alor upper") } },
    plaguelandsLarva = { mapName = "Eastern Plaguelands", location = "Carrion larva and grubbage circuit through the plague fields", targetUrl = "https://www.wowhead.com/zone=139/eastern-plaguelands", coords = { C(0.540, 0.610, "Lake Mereldar plague creatures"), C(0.440, 0.500, "Central plague fields"), C(0.320, 0.380, "Corin's Crossing edge") } },
    felwoodClaw = { mapName = "Felwood", location = "High-level beast circuit around Irontree Woods and Jadefire Run", targetUrl = "https://www.wowhead.com/zone=361/felwood", coords = { C(0.490, 0.180, "Irontree beast circuit"), C(0.430, 0.360, "Bloodvenom beasts"), C(0.486, 0.742, "Jadefire Run beasts") } },
    stranglethornClaw = { mapName = "Northern Stranglethorn", location = "Tiger, panther, and raptor circuit", targetUrl = "https://www.wowhead.com/npc=682/stranglethorn-tiger", coords = { C(0.382, 0.232, "Kurzen tiger route"), C(0.452, 0.438, "Central jungle cats"), C(0.548, 0.568, "Southern raptor return") } },
    tanarisEgg = { mapName = "Tanaris", location = "Roc and fire roc circuit west and south of Gadgetzan", targetUrl = "https://www.wowhead.com/npc=5428/roc", coords = { C(0.452, 0.388, "Gadgetzan west rocs"), C(0.424, 0.502, "Central desert rocs"), C(0.482, 0.612, "South desert fire rocs") } },
    lumber = { mapName = "Durotar", location = "Ironwood lumber-node circuit from the Valley of Trials toward Razor Hill", targetUrl = "https://www.wowhead.com/item=245586/ironwood-lumber", coords = { C(0.442, 0.680, "Valley of Trials lumber check"), C(0.506, 0.606, "South Durotar lumber node"), C(0.526, 0.438, "Razor Hill lumber check"), C(0.438, 0.392, "Thunder Ridge lumber check") } },
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
        researchStatus = "researched",
        sourceUrls = urls,
        summary = summary,
        spots = {
            {
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
RegisterReagent(5785, "Thick Murloc Scale", { "leatherworking" }, "Scale", "wetlandsMurloc", "Creature-drop scale used by mid-level leatherworking patterns.")
RegisterReagent(15420, "Ironfeather", { "leatherworking" }, "Specialty Reagent", "feralasFeather", "Hippogryph feather used by collectible leatherworking recipes.")
RegisterReagent(1475, "Small Venom Sac", { "alchemy", "miscellaneous" }, "Venom Sac", "wetlandsVenom", "Early creature reagent from spiders and venomous beasts.")
RegisterReagent(1288, "Large Venom Sac", { "alchemy", "miscellaneous" }, "Venom Sac", "dustwallowSpider", "Mid-level venom reagent from spiders and scorpids.")
RegisterReagent(3174, "Spider Ichor", { "alchemy", "miscellaneous" }, "Ichor", "wetlandsVenom", "Spider reagent used by old profession recipes.")
RegisterReagent(8151, "Flask of Mojo", { "alchemy", "miscellaneous" }, "Mojo", "hinterlandsTroll", "Troll reagent from dense Hinterlands camps.")
RegisterReagent(12804, "Powerful Mojo", { "alchemy", "miscellaneous" }, "Mojo", "hinterlandsTroll", "High-level troll reagent from Jintha'Alor-style camps.")
RegisterReagent(18512, "Larval Acid", { "alchemy", "leatherworking" }, "Acid", "plaguelandsLarva", "Rare plague-creature reagent used by specialty crafts.")
RegisterReagent(8146, "Wicked Claw", { "blacksmithing", "leatherworking" }, "Claw", "felwoodClaw", "High-level beast claw used by weapon and leather crafts.")
RegisterReagent(5635, "Sharp Claw", { "blacksmithing", "leatherworking" }, "Claw", "stranglethornClaw", "Mid-level beast claw from dense jungle routes.")
RegisterReagent(5637, "Large Fang", { "blacksmithing", "leatherworking" }, "Fang", "stranglethornClaw", "Large beast fang used by several old recipes.")
RegisterReagent(12207, "Giant Egg", { "cooking" }, "Egg", "tanarisEgg", "Cooking reagent from rocs, owlbears, and similar large birds.")
RegisterReagent(8150, "Deeprock Salt", { "leatherworking" }, "Salt", "badlandsEarth", "Rock-elemental drop used to cure Thick and Rugged Hides.")
RegisterReagent(245586, "Ironwood Lumber", { "miscellaneous" }, "Housing Lumber", "lumber", "Warband-bound lumber gathered in Classic zones for Midnight decor; useful for planning even though it cannot be auctioned.", "lumber-node-loop")

local DEVIATE_POUCH_PATTERN_ROUTE = {
    id = "classic-wailing-caverns-stuffed-deviate-pouch-patterns",
    source = "Wowhead retail Stuffed Deviate Scale Pouch page, pattern pages, and patch 10.1.5 collectables report",
    sourceUrls = {
        "https://www.wowhead.com/item=208015/stuffed-deviate-scale-pouch",
        "https://www.wowhead.com/news/wailing-cavern-collectables-return-in-patch-10-1-5-farm-legacy-items-and-334262",
        "https://www.wowhead.com/npc=3840/druid-of-the-fang",
    },
    mapName = "Northern Barrens",
    location = "Wailing Caverns Druid of the Fang clears",
    routeType = "dungeon-container-content-farm",
    density = "Repeatable dungeon clear",
    dropDifficulty = "Layered RNG: Druids of the Fang drop a bind-on-pickup pouch, then the pouch rolls one legacy reward.",
    tips = {
        "The Stuffed Deviate Scale Pouch itself is bind-on-pickup and is intentionally not an auction item in the catalog.",
        "Open every pouch and auction the tradeable legacy patterns; the cloak, gloves, and belt patterns can repeat.",
        "Keep Deviate Scale and Perfect Deviate Scale from the same runs for the crafted transmog chain.",
    },
    coords = {
        C(0.462, 0.358, "Wailing Caverns entrance"),
        C(0.478, 0.374, "Outer cavern and reset anchor"),
    },
    confidence = "high",
}

for itemID, itemName in pairs({
    [6474] = "Pattern: Deviate Scale Cloak",
    [6475] = "Pattern: Deviate Scale Gloves",
    [6476] = "Pattern: Deviate Scale Belt",
}) do
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "classic",
        professions = { "leatherworking", "miscellaneous" },
        category = "Legacy Pattern",
        researchStatus = "researched",
        sourceUrls = { ItemUrl(itemID), "https://www.wowhead.com/item=208015/stuffed-deviate-scale-pouch" },
        summary = "Tradeable legacy leatherworking pattern found by opening bind-on-pickup Stuffed Deviate Scale Pouches from Druids of the Fang.",
        spots = { DEVIATE_POUCH_PATTERN_ROUTE },
    })
end
