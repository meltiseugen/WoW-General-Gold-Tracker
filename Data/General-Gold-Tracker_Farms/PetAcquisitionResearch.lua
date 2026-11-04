local _, NS = ...

-- Additional AH pets researched 2026-10-21. Species IDs drive pet pricing;
-- acquisition items are never confused with the shared Battle Pet Cage (82800).
-- Points mark named sources, entrances or explicitly labelled farming anchors.
local expansions = {
    [1] = { "classic", "Classic" },
    [2] = { "burningCrusade", "The Burning Crusade" },
    [3] = { "wrath", "Wrath of the Lich King" },
    [4] = { "cataclysm", "Cataclysm" },
    [5] = { "mists", "Mists of Pandaria" },
    [6] = { "warlords", "Warlords of Draenor" },
    [7] = { "legion", "Legion" },
    [8] = { "battleForAzeroth", "Battle for Azeroth" },
    [9] = { "shadowlands", "Shadowlands" },
    [10] = { "dragonflight", "Dragonflight" },
    [11] = { "warWithin", "The War Within" },
    [12] = { "midnight", "Midnight" },
}

local function Point(x, y, label)
    return { x = x / 100, y = y / 100, label = label }
end

local function Spot(mapID, mapName, location, role, coords)
    return {
        mapID = mapID, mapName = mapName, location = location,
        mapRole = role, routeType = "farm-pet", isRoute = false,
        confidence = "medium", density = "Named source or farming-area anchor",
        dropDifficulty = "Yield varies; follow the source requirements and repeatability notes.",
        coords = coords,
    }
end

local function Pet(data)
    local expansion = expansions[data.contentID]
    data.expansion, data.expansionLabel = expansion[1], expansion[2]
    data.researchedAt = data.researchedAt or "2026-10-21"
    data.cageable = true
    data.saleMethod = data.saleMethod or "learn-and-cage"
    data.guideLabel = "Pet acquisition - " .. data.expansionLabel
    data.summary = data.itemName .. ": " .. data.action
    data.tips = data.tips or {}
    data.tips[#data.tips + 1] = data.repeatability
    data.tips[#data.tips + 1] = data.saleMethod == "item-or-cage"
        and "The unlearned pet item can be auctioned; the learned pet can also be caged for sale."
        or "The acquisition reward is bound or learned directly. Learn it, then use Put in Cage in the Pet Journal to sell it on the Auction House."
    for index, spot in ipairs(data.spots) do
        spot.id = "ah-pet-" .. data.petID .. "-" .. index
        spot.farmAction = data.action
        spot.sourceUrls = data.sourceUrls
        spot.tips = data.tips
    end
    return data
end

local rows = {
    Pet {
        petID = 50, itemName = "Green Wing Macaw", contentID = 1,
        acquisitionType = "dungeon-trash", saleMethod = "item-or-cage",
        requirement = "Enter the ordinary Deadmines dungeon through the Moonbrook mine in Westfall.",
        action = "Clear Defias Pirates near the ship at the end of The Deadmines and loot the Parrot Cage (Green Wing Macaw).",
        repeatability = "Normal dungeon resets provide more trash attempts, subject to the account's instance-entry limit.",
        tips = { "The exterior marker is the mine approach. Follow the mine tunnels to the dungeon portal; the pet drops inside, not at the entrance." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/flying/parrots/green-wing-macaw/",
            "https://www.wowhead.com/zone=1581/the-deadmines",
            "https://www.wowhead.com/npc=7387/green-wing-macaw",
        },
        spots = { Spot(52, "Westfall", "Moonbrook mine approach - The Deadmines", "entrance", {
            Point(42.56, 71.53, "Deadmines mine approach; continue inside to the portal"),
        }) },
    },
    Pet {
        petID = 175, itemName = "Phoenix Hatchling", contentID = 2,
        acquisitionType = "dungeon-boss",
        requirement = "Reach the original Isle of Quel'Danas and enter Magisters' Terrace.",
        action = "Defeat Kael'thas Sunstrider at the end of Magisters' Terrace for a chance at Phoenix Hatchling.",
        repeatability = "The pet drops on Normal and Heroic. Normal resets allow repeat attempts; Heroic has a daily lockout.",
        tips = { "Use the original Burning Crusade dungeon. The pin marks its exterior entrance, not the Midnight dungeon or the boss room." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/elemental/mythical/phoenix-hatchling/",
            "https://wow.gg/guides/swift-white-hawkstrider-mount-guide",
        },
        spots = { Spot(122, "Isle of Quel'Danas", "Original Magisters' Terrace entrance", "entrance", {
            Point(61.3, 30.9, "Original Magisters' Terrace entrance - Kael'thas inside"),
        }) },
    },
    Pet {
        petID = 193, itemName = "Giant Sewer Rat", contentID = 3,
        acquisitionType = "fishing",
        requirement = "Learn Fishing and travel to Northrend Dalaran's Underbelly.",
        action = "Fish open sewer water by the Cantrips & Crows pier in Northrend Dalaran for a rare Giant Sewer Rat catch.",
        repeatability = "Repeat casts are allowed; no fixed number of casts guarantees a pet.",
        tips = { "Use the Underbelly floor in the map selector. This is a fishing-area marker, not a rat to kill or capture." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/critter/rats-and-mice/giant-sewer-rat/",
            "https://www.wowhead.com/achievement=1958/i-smell-a-giant-rat",
            "https://www.wowhead.com/quest=13832/jewel-of-the-sewers",
        },
        spots = { Spot(126, "Dalaran - The Underbelly", "Cantrips & Crows sewer fishing pier", "fishing-area", {
            Point(44.75, 65.96, "Cantrips & Crows fishing pier - open sewer water"),
        }) },
    },
    Pet {
        petID = 293, itemName = "Elementium Geode", contentID = 4,
        acquisitionType = "mining", saleMethod = "item-or-cage",
        requirement = "Learn Cataclysm Mining and gather Elementium Veins or Rich Elementium Veins.",
        action = "Mine Elementium nodes in Twilight Highlands for a rare Elementium Geode bonus drop.",
        repeatability = "Repeat eligible node gathers; a mining pass does not guarantee the pet.",
        tips = { "The marker is a northern mining-area anchor from the researched Elementium circuit. Search surrounding ridges for nodes; it is not a fixed pet spawn." },
        sourceUrls = {
            "https://www.wowhead.com/npc=50722/elementium-geode",
            "https://www.wowhead.com/news/cataclysm-companion-pets-guide-gotta-catch-em-all-176437",
            "https://www.wow-professions.com/farming/elementium-ore-farming",
        },
        spots = { Spot(241, "Twilight Highlands", "Northern ridges - Elementium mining area", "gathering-area", {
            Point(44.58, 19.90, "Elementium mining-area anchor; search nearby ridges"),
        }) },
    },
    Pet {
        petID = 1532, itemName = "Ikky", contentID = 6,
        acquisitionType = "quest",
        requirement = "Progress the Spires of Arak story through The Kaliri Whisperer.",
        action = "Complete Ikky's Egg and the feeding follow-up, then return to Veil Terokk for the final Ikky quest that teaches the pet.",
        repeatability = "This is a one-time quest chain per eligible character; use another character for another reward.",
        tips = { "The pin marks the egg and quest start. If the egg is missing, finish the prerequisite story instead of waiting for a rare spawn." },
        sourceUrls = {
            "https://www.wow-petguide.com/Pet/86447/Ikky?sel_lang=en",
            "https://www.wowhead.com/npc=86447/ikky",
        },
        spots = { Spot(542, "Spires of Arak", "Ikky's Egg quest start", "quest", {
            Point(45.4, 36.6, "Ikky's Egg - finish the chain and return to Veil Terokk"),
        }) },
    },
    Pet {
        petID = 1934, itemName = "Benax", contentID = 7,
        acquisitionType = "rare-drop",
        requirement = "Reach Meredil in Suramar and find Anax by the water near Shal'Aran.",
        action = "Defeat Anax in Suramar and loot Benax.",
        repeatability = "Legion vignette rare rewards are generally one-time per character. Use an eligible alt rather than repeatedly killing a completed rare.",
        tips = { "Check the small island and tree by the water. The pin names Anax, not a capturable Benax spawn." },
        sourceUrls = {
            "https://www.wowhead.com/npc=113136/benax",
            "https://www.cymre.com/2016/06/13/legion-battle-pets/",
        },
        spots = { Spot(680, "Suramar", "Meredil - Anax", "rare", { Point(33.7, 51.8, "Anax - Benax reward") }) },
    },
    Pet {
        petID = 1907, itemName = "Pygmy Owl", contentID = 7,
        acquisitionType = "event-rare",
        requirement = "Speak to Lorel Sagefeather in Whispering Bluffs to summon Gorebeak.",
        action = "Summon and defeat Gorebeak in Val'sharah to obtain Pygmy Owl.",
        repeatability = "Treat this as a one-time Legion rare reward per character; use eligible alts for additional pets.",
        tips = { "Gorebeak is summoned through the local NPC interaction; an empty marker does not by itself mean the rare is on a respawn timer." },
        sourceUrls = {
            "https://www.wowhead.com/item=130154/pygmy-owl",
            "https://www.wowhead.com/npc=108568/pygmy-owl",
            "https://warcraft.wiki.gg/wiki/Gorebeak",
        },
        spots = { Spot(641, "Val'sharah", "Whispering Bluffs - Gorebeak event", "event-rare", {
            Point(59.8, 77.3, "Gorebeak - speak to Lorel Sagefeather nearby"),
        }) },
    },
    Pet {
        petID = 1721, itemName = "Stormborne Whelpling", contentID = 7,
        acquisitionType = "rare-drop",
        requirement = "Reach Stormwing Rookery on the southern Stormheim mountain.",
        action = "Defeat Stormwing Matriarch in Stormheim for Stormborne Whelpling.",
        repeatability = "The Legion rare reward is one-time per eligible character; plan extra pets on alts.",
        tips = { "The rookery is elevated. Use the mountain path or flight; the pin is not on the road below." },
        sourceUrls = {
            "https://www.wowhead.com/npc=97205/stormborne-whelpling",
            "https://www.warcraftpets.com/wow-pets/dragonkin/dragon-whelps/stormborne-whelpling/",
        },
        spots = { Spot(634, "Stormheim", "Stormwing Rookery", "rare", {
            Point(49.6, 72.0, "Stormwing Matriarch - elevated rookery"),
        }) },
    },
    Pet {
        petID = 2847, itemName = "Rotbreath", contentID = 8,
        acquisitionType = "assault-rare",
        requirement = "Unlock Visions of N'Zoth assaults and use the assault version of Uldum while the Aqir assault is active.",
        action = "Enter Lord Aj'qirai's cave during the Aqir assault and defeat him for the Stinky Sack that teaches Rotbreath.",
        repeatability = "The rare must be available in the current assault rotation; eligible daily rare loot attempts are per character.",
        tips = { "The marker is the cave entrance. Continue inside to the rare; original pre-assault Uldum is a different phase." },
        sourceUrls = {
            "https://www.wowhead.com/npc=161997/rotbreath",
            "https://www.wowhead.com/guide/battle-pets-visions-of-nzoth",
        },
        spots = { Spot(1527, "Uldum (N'Zoth assault)", "Lord Aj'qirai cave entrance", "entrance", {
            Point(36.85, 20.93, "Lord Aj'qirai cave entrance - Aqir assault phase"),
        }) },
    },
    Pet {
        petID = 2848, itemName = "Aqir Tunneler", contentID = 8,
        acquisitionType = "assault-rare",
        requirement = "Unlock Visions of N'Zoth assaults and visit Uldum during the Aqir minor assault.",
        action = "Find and defeat the flying rare Skikx'traz for Black Chitinous Plate, which teaches Aqir Tunneler.",
        repeatability = "Available during the Aqir assault rotation, with eligible daily rare loot attempts per character.",
        tips = { "The pin is a flying-rare search anchor. Look above the terrain and nearby patrol area; it is not a guaranteed ground spawn." },
        sourceUrls = {
            "https://www.wowhead.com/npc=162004/aqir-tunneler",
            "https://www.wowhead.com/guide/battle-pets-visions-of-nzoth",
        },
        spots = { Spot(1527, "Uldum (N'Zoth assault)", "Skikx'traz flying-rare search area", "patrol", {
            Point(21.20, 61.03, "Skikx'traz flying patrol anchor - Aqir assault"),
        }) },
    },
    Pet {
        petID = 2845, itemName = "K'uddly", contentID = 8,
        acquisitionType = "assault-rare",
        requirement = "Unlock Visions of N'Zoth assaults and enter the Black Empire assault phase of the Vale of Eternal Blossoms.",
        action = "Defeat The Forgotten on its floating platform for a chance at K'uddly.",
        repeatability = "The source follows the Vale assault rotation; use eligible daily rare loot attempts on additional characters.",
        tips = { "The target is on a platform in the sky. The marker uses the assault map, not the original Pandaria Vale." },
        sourceUrls = {
            "https://www.wowhead.com/npc=161954/kuddly",
            "https://www.wowhead.com/guide/battle-pets-visions-of-nzoth",
        },
        spots = { Spot(1530, "Vale of Eternal Blossoms (N'Zoth assault)", "The Forgotten - floating platform", "rare", {
            Point(51.85, 42.19, "The Forgotten - platform in the sky"),
        }) },
    },
    Pet {
        petID = 3008, itemName = "Lost Quill", contentID = 9,
        acquisitionType = "treasure",
        requirement = "Collect Forbidden Ink inside the Forbidden Library before speaking to the quill above it.",
        action = "Pick up the Forbidden Ink, then bring it to Lost Quill on the wall above the library to receive Refilling Inkwell.",
        repeatability = "Treat the treasure as one-time per eligible character; use alts for additional sale copies.",
        tips = { "The two pins distinguish the ink inside the library and the quill on the upper wall. The quill cannot be reached by standing directly below it." },
        sourceUrls = {
            "https://www.wowhead.com/npc=173508/lost-quill",
            "https://www.warcraftpets.com/wow-pets/magic/miscellaneous/lost-quill/",
        },
        spots = { Spot(1525, "Revendreth", "Forbidden Library - ink and upper-wall quill", "treasure", {
            Point(37.68, 68.74, "Forbidden Ink - inside the library"),
            Point(37.76, 69.27, "Lost Quill - upper wall; bring Forbidden Ink"),
        }) },
    },
    Pet {
        petID = 3022, itemName = "Shimmerbough Hoarder", contentID = 9,
        acquisitionType = "treasure",
        requirement = "Find the Faerie Trove beneath the fallen tree south of Refugee Camp.",
        action = "Enter from the river and loot the Faerie Trove underneath the tree in Ardenweald.",
        repeatability = "One-time treasure per eligible character; additional characters provide more copies.",
        tips = { "The chest is underneath the terrain in a small cave. Approach from the river, not the top of the log." },
        sourceUrls = {
            "https://www.wowhead.com/npc=173591/shimmerbough-hoarder",
            "https://www.wowhead.com/guide/shadowlands-battle-pets",
        },
        spots = { Spot(1565, "Ardenweald", "Faerie Trove - river entrance beneath tree", "treasure", {
            Point(49.70, 55.88, "Faerie Trove underneath tree - enter from river"),
        }) },
    },
    Pet {
        petID = 3365, itemName = "Roseate Hopper", contentID = 10,
        acquisitionType = "treasure-puzzle",
        requirement = "Collect the three riddle ingredients in The Waking Shores before returning to the Possessive Hornswog.",
        action = "Combine Adventurer's Lost Soap Bar, Marmoni's Prize and Well-Preserved Bone near the hornswog, then loot Hidden Hornswog Hostage.",
        repeatability = "The treasure puzzle is one-time per eligible character; repeat on alts for more pets.",
        tips = { "The map includes all three ingredient locations and the final hornswog. Read Observant Riddles: A Field Guide at the final location." },
        sourceUrls = {
            "https://www.wowhead.com/npc=192369/roseate-hopper",
            "https://www.warcraftpets.com/wow-pets/aquatic/frogs-and-toads/roseate-hopper/",
        },
        spots = { Spot(2022, "The Waking Shores", "Hidden Hornswog Hostage - puzzle and ingredients", "treasure", {
            Point(64.93, 69.60, "Possessive Hornswog - combine ingredients here"),
            Point(39.64, 84.69, "Adventurer's Lost Soap Bar - near barrel"),
            Point(47.71, 83.59, "Marmoni's Prize - boxes behind tent"),
            Point(66.18, 55.29, "Well-Preserved Bone - top of tower"),
        }) },
    },
    Pet {
        petID = 3321, itemName = "Blackfeather Nester", contentID = 10,
        acquisitionType = "treasure",
        requirement = "Reach the hollow tree trunk near Traitor's Rest in The Azure Span.",
        action = "Collect Tree Sap inside the trunk, use the stick near the top to lure Pepper Hammer, then interact with the bird for Blackfeather Nester.",
        repeatability = "This is a one-time treasure per eligible character; use alts for additional copies.",
        tips = { "Tree Sap lasts five minutes. If the stick is unresponsive, a UI reload has resolved it in player reports." },
        sourceUrls = {
            "https://www.wowhead.com/npc=189156/blackfeather-nester",
            "https://www.warcraftpets.com/wow-pets/flying/miscellaneous/blackfeather-nester/",
        },
        spots = { Spot(2024, "The Azure Span", "Traitor's Rest hollow tree - Pepper Hammer", "treasure", {
            Point(26.52, 46.18, "Tree Sap, stick and Pepper Hammer in the hollow trunk"),
        }) },
    },
    Pet {
        petID = 3319, itemName = "Yipper", contentID = 10,
        acquisitionType = "quest",
        requirement = "Speak to Zon'Wogi beside the flight master at Three-Falls Lookout.",
        action = "Accept The Great Shokhari, defeat the quest target and return to Zon'Wogi for Yipper.",
        repeatability = "One quest reward per eligible character; use alts for further sale copies.",
        tips = { "The marker is the quest giver and turn-in, not the enemy. Follow the quest objective to find the slyvern." },
        sourceUrls = {
            "https://www.wowhead.com/npc=189204/yipper",
            "https://www.warcraftpets.com/wow-pets/flying/miscellaneous/yipper/",
        },
        spots = { Spot(2024, "The Azure Span", "Three-Falls Lookout - Zon'Wogi", "quest", {
            Point(19.0, 24.0, "Zon'Wogi - The Great Shokhari quest start and turn-in"),
        }) },
    },
    Pet {
        petID = 4482, itemName = "Writhing Transmutagen", contentID = 11,
        acquisitionItemID = 223487, acquisitionType = "thaumaturgy-proc", saleMethod = "item-or-cage",
        researchedAt = "2026-10-23",
        requirement = "Learn Khaz Algar Alchemy and unlock the Thaumaturgy specialization, available from skill 25.",
        action = "Use Khaz Algar Thaumaturgy on eligible reagents for a chance to discover Writhing Transmutagen.",
        repeatability = "Each eligible Thaumaturgy use consumes reagents and gives a chance at the pet; no fixed drop rate, guaranteed result or profitable input is assumed.",
        tips = {
            "Reports include Storm Dust and transmutagen inputs; an expensive quality-three Storm Dust input is not established as mandatory.",
            "Thaumaturgy is a profession action, not a creature farm. The Khaz Algar map provides expansion context without a fixed farming pin.",
            "The pet item is separate from the bound Ominous, Mercurial, Volatile and Gleaming Transmutagen reagents.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=223487/writhing-transmutagen",
            "https://www.warcraftpets.com/wow-pets/magic/oozes-and-slimes/writhing-transmutagen/",
            "https://www.wow-petguide.com/Pet/222359/Writhing_Transmutagen?sel_lang=en",
        },
        spots = { {
            mapID=2274, mapName="Khaz Algar", location="Khaz Algar Alchemy - Thaumaturgy",
            mapRole="profession-context", routeType="farm-pet", isRoute=false,
            mapOnly=true, coords={}, confidence="profession-source", inGameTested=false,
            density="Random profession result; no fixed farming location",
            dropDifficulty="Requires the Thaumaturgy unlock and consumed inputs; no guaranteed pet or measured yield.",
        } },
    },
    Pet {
        petID = 4726, itemName = "Crackleroar", contentID = 11,
        acquisitionType = "storm-drop",
        requirement = "Unlock Siren Isle and talk to Suzie Boltwrench to enter the storm phase.",
        action = "Farm Stormtouched Pridetalons on Siren Isle's high peaks during the storm; Tempest Talon can also drop Crackleroar.",
        repeatability = "Ordinary Stormtouched Pridetalons allow repeated attempts while the storm phase is active.",
        tips = { "Bring Experimental Go-Packs to move between peaks. The marked ordinary-enemy locations are farming anchors, not the Tempest Talon rare spawn." },
        sourceUrls = {
            "https://www.wowhead.com/item=234379/crackleroar",
            "https://www.wowhead.com/npc=235124/crackleroar",
        },
        spots = { Spot(2369, "Siren Isle", "Stormtouched Pridetalon mountain farming areas", "farming-area", {
            Point(54.93, 23.54, "Northern peak - storm-phase Pridetalons"),
            Point(51.27, 19.94, "Northern Pridetalon farming anchor"),
            Point(41.88, 60.34, "Southwestern Pridetalon farming anchor"),
        }) },
    },
    Pet {
        petID = 2541, itemName = "Proper Parrot", contentID = 11,
        acquisitionType = "invasion-drop",
        requirement = "Visit Siren Isle while the pirate invasion is active.",
        action = "Defeat Bilge Rat pirates, including the named elites and rares, for Proper Parrot.",
        repeatability = "Pirate kills can provide repeated attempts during the pirate invasion; the pet is not a guaranteed rare reward.",
        tips = { "The species was originally unused BFA data; this entry is grouped under its obtainable Siren Isle source in The War Within." },
        sourceUrls = {
            "https://www.wowhead.com/item=166358/proper-parrot",
            "https://www.wow-petguide.com/News/515",
            "https://warcraft.wiki.gg/wiki/BattlePetSpeciesID",
        },
        spots = { Spot(2369, "Siren Isle", "Pirate invasion - named Bilge Rat enemies", "farming-area", {
            Point(51, 62, "Bicephalic Bill - pirate invasion"),
            Point(55, 68, "Timmy Two-Tongue - pirate invasion"),
            Point(65, 65, "Spare-Head Ed - pirate invasion"),
            Point(61.14, 68.89, "First Mate Shellshock - pirate invasion"),
            Point(62.2, 90.4, "Twin-Dome Doug - pirate invasion"),
            Point(61, 48, "Bert and Benny - pirate invasion"),
            Point(48, 70, "Finny Four-Eyes - pirate invasion"),
            Point(66, 85, "Chef Chum Platter - pirate invasion rare"),
            Point(59, 87, "Plank-Master Bluebelly - pirate invasion rare"),
        }) },
    },
    Pet {
        petID = 4928, itemName = "Dragonhawk Munchkin", contentID = 12,
        acquisitionType = "renown-vendor",
        requirement = "Earn Renown 12 with the Silvermoon Court and bring 2,500 Voidlight Marl.",
        action = "Buy Dragonhawk Munchkin from Caeris Fairdawn at Saltheril's Haven, then learn and cage it for sale.",
        repeatability = "Vendor stock is unlimited once unlocked; each purchase costs currency and still requires learning and caging.",
        tips = { "Use the Midnight Eversong Woods map. This is a currency-to-pet option; compare the pet's market before spending Marl." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/dragonkin/dragonhawks/dragonhawk-munchkin/",
            "https://www.wowhead.com/npc=240838/caeris-fairdawn",
            "https://www.wowhead.com/npc=255257/dragonhawk-munchkin",
        },
        spots = { Spot(2395, "Eversong Woods (Midnight)", "Saltheril's Haven - Caeris Fairdawn", "vendor", {
            Point(43.46, 47.42, "Caeris Fairdawn - Silvermoon Court Renown 12"),
        }) },
    },
    Pet {
        petID = 5040, itemName = "Curious Lynx Kitten", contentID = 12,
        acquisitionType = "rotating-event-cache", saleMethod = "item-or-cage",
        requirement = "Unlock Void Assaults and participate in Eversong Woods Void Strikes during the Eversong rotation.",
        action = "Complete Eversong Woods Void Strikes for a chance at a Wriggling Field Pouch containing Curious Lynx Kitten.",
        repeatability = "Repeat active Void Strikes during the correct zone rotation; the pouch replaces the ordinary reward only occasionally.",
        tips = { "Pins mark two documented Void Strike locations. Check the active event on the world map; neither pin is a permanent pet or chest spawn." },
        sourceUrls = {
            "https://www.wowhead.com/npc=262788/curious-lynx-kitten",
            "https://www.warcraftpets.com/wow-pets/beast/felines/curious-lynx-kitten/",
            "https://www.wowhead.com/guide/collections/midnight-battle-pets-locations-sources",
            "https://www.wowhead.com/achievement=62570/cosmic-slayer",
        },
        spots = { Spot(2395, "Eversong Woods (Midnight)", "Eversong Void Strikes - rotating event anchors", "event", {
            Point(53, 39.4, "Void Ritual: Springclaw - only when active"),
            Point(56, 76.8, "Void Ritual: Croaker - only when active"),
        }) },
    },
    Pet {
        petID = 5038, itemName = "Wriggling Capybara", contentID = 12,
        acquisitionType = "rotating-event-cache", saleMethod = "item-or-cage",
        requirement = "Unlock Void Assaults and participate in Zul'Aman Void Strikes during the Zul'Aman rotation.",
        action = "Complete Zul'Aman Void Strikes for a chance at a Wriggling Field Pouch containing Wriggling Capybara.",
        repeatability = "Repeat active Void Strikes during the correct zone rotation; no published guaranteed attempt count is assumed.",
        tips = { "The Grizzly ritual pin is a documented event anchor. Follow the current world-map event; the pet does not spawn at the marker." },
        sourceUrls = {
            "https://www.wowhead.com/npc=262786/wriggling-capybara",
            "https://www.warcraftpets.com/wow-pets/beast/rodents/wriggling-capybara/",
            "https://www.wowhead.com/guide/collections/midnight-battle-pets-locations-sources",
            "https://www.wowhead.com/achievement=62570/cosmic-slayer",
        },
        spots = { Spot(2437, "Zul'Aman (Midnight)", "Zul'Aman Void Strikes - rotating event anchor", "event", {
            Point(32, 71.6, "Void Ritual: Grizzly! - only when active"),
        }) },
    },
}

-- The four crocolisks share Barlo's fishing daily, but retain separate species,
-- records, source pages and AH identities. Pin the shared quest giver.
for _, pet in ipairs({ {163, "Toothy"}, {164, "Muckbreath"}, {173, "Snarly"}, {174, "Chuck"} }) do
    rows[#rows + 1] = Pet {
        petID = pet[1], itemName = pet[2], contentID = 2,
        acquisitionType = "fishing-daily",
        requirement = "Learn Fishing and check Old Man Barlo's daily at Slimyr Lake in Terokkar Forest.",
        action = "Complete Crocolisks in the City when offered, then open that daily's Bag of Fishing Treasures for a chance at the crocolisk pet.",
        repeatability = "Barlo offers one of five daily quests. Only Crocolisks in the City has these pets; use eligible characters when it is offered.",
        tips = { "Pick up the quest in Outland, fish the quest crocolisk in the Stormwind or Orgrimmar city water, then return to Barlo. The pin marks Barlo, not a direct pet drop." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/aquatic/crocolisks/" .. pet[2]:lower() .. "/",
            "https://www.wow-petguide.com/News/412/Burning_Crusade_Timewalking_2023-04-26?sel_lang=en",
            "https://www.wowhead.com/quest=11665/crocolisks-in-the-city",
        },
        spots = {
            Spot(108, "Terokkar Forest", "Slimyr Lake - Old Man Barlo", "quest", { Point(38.6, 12.8, "Old Man Barlo - quest start and turn-in") }),
        },
    }
end

-- Four separate saleable raptors from the same Dinomancer farm. The ship pin
-- is an area anchor cross-checked against War-God Dokah and his Dinomancers.
for _, pet in ipairs({ {1180, "Zandalari Kneebiter"}, {1211, "Zandalari Anklerender"}, {1212, "Zandalari Footslasher"}, {1213, "Zandalari Toenibbler"} }) do
    rows[#rows + 1] = Pet {
        petID = pet[1], itemName = pet[2], contentID = 5,
        acquisitionType = "open-world-drop",
        requirement = "Travel to Isle of Giants and find the Zandalari Dinomancers around the ships.",
        action = "Kill Zandalari Dinomancers for a chance at any of the four Zandalari raptor pets.",
        repeatability = "Ordinary Dinomancers can be farmed repeatedly; their loot is random and does not guarantee the desired raptor.",
        tips = { "The southeastern ship marker is a farming-area anchor. Clear Dinomancers on and around the ships; do not mistake the nearby dinosaurs for the primary raptor-pet source." },
        sourceUrls = {
            "https://www.warcraftpets.com/wow-pets/beast/raptors/" .. pet[2]:lower():gsub(" ", "-") .. "/",
            "https://www.wow-petguide.com/Pet/70451/Zandalari_Anklerender?sel_lang=en",
            "https://www.wowhead.com/npc=70096/war-god-dokah",
            "https://warcraft.wiki.gg/wiki/BattlePetSpeciesID",
        },
        spots = { Spot(507, "Isle of Giants", "Southeastern Zandalari ship - Dinomancer farm", "farming-area", {
            Point(78.2, 81.4, "Southeastern ship - Dinomancers around War-God Dokah"),
        }) },
    }
end

NS.PetAcquisitionResearch = rows
