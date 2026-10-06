local _, NS = ...

-- Curated Retail acquisition research for every visible Drops > Toys row.
-- Coordinates are normalized UI-map coordinates. Research reviewed 2026-10-03.

local researchByFarmID = {
    WornTrollDice = {
        name = "Worn Troll Dice",
        mapOptions = {
            {
                id = "ggt:toy:worn-troll-dice:skorn-loop",
                mapID = 117,
                mapLabel = "Howling Fjord",
                label = "Skorn tower pickpocket loop",
                location = "Skorn",
                isRoute = true,
                density = "Four tower packs plus the vrykul between them",
                dropDifficulty = "Extremely rare Pick Pocket loot; only a Rogue can farm it directly.",
                pins = {
                    { x = 0.440, y = 0.300, label = "Northwest tower" },
                    { x = 0.460, y = 0.320, label = "East tower" },
                    { x = 0.460, y = 0.360, label = "Southeast tower" },
                    { x = 0.430, y = 0.360, label = "Southwest tower" },
                },
            },
        },
        summary = "Worn Troll Dice are rare Pick Pocket loot from Northrend humanoids. Skorn is the most consistently documented circuit because its four tower packs and surrounding vrykul refill while a Rogue completes the loop.",
        guide = {
            label = "Rogue pickpocket circuit",
            requirement = "Use a Rogue with Pick Pocket and reach Skorn in Howling Fjord; flying makes the tower circuit much faster.",
            action = "Pickpocket every vrykul around the four marked towers, then clear or move on so the packs can reset before the next lap.",
            tips = {
                "The dice come from Pick Pocket loot, not the normal corpse loot table.",
                "Comments repeatedly recommend concentrating on the four tower mage packs; complete the loop clockwise and include nearby ground mobs while waiting for the first tower to refill.",
                "The chance is very low and reports range from a few circuits to many hours, so count pockets rather than expecting a fixed run total.",
                "If Skorn is crowded, Hrothgar's Landing, Gjalerbron, and Jotunheim are documented alternatives with eligible Northrend humanoids.",
            },
        },
        details = {
            "The pins trace the four Skorn towers at approximately 44,30; 46,32; 46,36; and 43,36.",
            "The WIT row names Howling Fjord; this route refines that broad zone label to the specific Skorn farm.",
        },
        sourceUrls = {
            { siteName = "Wowhead item comments", url = "https://www.wowhead.com/item=36862/worn-troll-dice" },
            { siteName = "Wowhead archived pickpocket guide", url = "https://www.wowhead.com/guide/rolling-the-dice-a-pick-pocketing-guide-to-northrend-dice-archive-341" },
            { siteName = "Warcraft Wiki source summary", url = "https://warcraft.wiki.gg/wiki/Worn_Troll_Dice" },
        },
    },
    DecahedralDwarvenDice = {
        name = "Decahedral Dwarven Dice",
        mapOptions = {
            {
                id = "ggt:toy:decahedral-dwarven-dice:new-hearthglen-loop",
                mapID = 115,
                mapLabel = "Dragonblight",
                label = "New Hearthglen pickpocket loop",
                location = "New Hearthglen",
                isRoute = true,
                density = "Compact Scarlet Onslaught circuit with little downtime",
                dropDifficulty = "Extremely rare Pick Pocket loot; only a Rogue can farm it directly.",
                pins = {
                    { x = 0.729, y = 0.681, label = "North approach and gate" },
                    { x = 0.736, y = 0.718, label = "Courtyard packs" },
                    { x = 0.721, y = 0.751, label = "Training grounds" },
                    { x = 0.709, y = 0.777, label = "Cathedral and south turn" },
                },
            },
        },
        summary = "Decahedral Dwarven Dice are rare Pick Pocket loot from Northrend humanoids. New Hearthglen's dense Scarlet Onslaught route is a better actionable farm than the WIT row's broad Icecrown label.",
        guide = {
            label = "Rogue pickpocket circuit",
            requirement = "Use a Rogue with Pick Pocket and travel to New Hearthglen in southeastern Dragonblight.",
            action = "Loop from the north gate through the courtyard and training grounds, pickpocketing every Scarlet Onslaught humanoid before turning back near the cathedral.",
            tips = {
                "The dice are obtained through Pick Pocket; killing without pickpocketing does not provide the intended attempt.",
                "New Hearthglen is commonly recommended because the circuit is compact and fresh targets respawn while the loop is completed.",
                "Onslaught Harbor in Icecrown is a documented backup if another Rogue is disrupting the New Hearthglen circuit.",
                "The individual chance is very low, so additional eligible targets per minute matter more than camping one NPC.",
            },
        },
        details = {
            "New Hearthglen is centered around 72,73 in Dragonblight; the pins follow its north-to-south Scarlet Onslaught packs.",
            "This researched route intentionally differs from the imported Icecrown location because the best documented farm is in Dragonblight.",
        },
        sourceUrls = {
            { siteName = "Wowhead item comments", url = "https://www.wowhead.com/item=36863/decahedral-dwarven-dice" },
            { siteName = "wow.gg farming guide", url = "https://wow.gg/guides/decahedral-dwarven-dice-toy-guide" },
            { siteName = "Warcraft Wiki source summary", url = "https://warcraft.wiki.gg/wiki/Decahedral_Dwarven_Dice" },
        },
    },
    LoadedGnomishDice = {
        name = "Loaded Gnomish Dice",
        mapOptions = {
            {
                id = "ggt:toy:loaded-gnomish-dice:makers-ascent",
                mapID = 249,
                mapLabel = "Uldum",
                label = "Maker's Ascent pickpocket packs",
                location = "Maker's Ascent",
                isRoute = true,
                density = "Repeated groups of nine infantry with one elite",
                dropDifficulty = "Extremely rare Pick Pocket loot; comment reports commonly describe hundreds or thousands of attempts.",
                pins = {
                    { x = 0.336, y = 0.270, label = "Lower Schnottz Infantry pack" },
                    { x = 0.342, y = 0.257, label = "Middle ascent pack" },
                    { x = 0.350, y = 0.244, label = "Upper ascent pack" },
                },
            },
        },
        summary = "Loaded Gnomish Dice are rare Pick Pocket loot from Cataclysm humanoids. The Schnottz Infantry groups at Maker's Ascent are the most heavily documented farm and provide many pockets in a small area.",
        guide = {
            label = "Rogue pickpocket circuit",
            requirement = "Use a Rogue with Pick Pocket and reach the northwest Uldum staircase around 34,27.",
            action = "Sap each group's elite to halt the formation, pickpocket the surrounding infantry, then move uphill through the marked packs.",
            tips = {
                "Only Pick Pocket attempts matter for the dice; the normal kill loot table is not the source.",
                "Sapping the elite stops the moving formation and makes the nine surrounding infantry much easier to reach safely.",
                "Comments confirm the Maker's Ascent source in modern Retail, but also report streaks of 1,200-3,000 attempts; expect severe RNG.",
                "Tol Barad Peninsula and the Chamber of the Moon are lower-competition alternatives when Maker's Ascent is occupied.",
            },
        },
        details = {
            "The primary pin is the repeatedly reported 34,27 Schnottz Infantry location.",
            "The three pins follow the staircase packs rather than marking Uldum's zone center.",
        },
        sourceUrls = {
            { siteName = "Wowhead item comments", url = "https://www.wowhead.com/item=63269/loaded-gnomish-dice" },
            { siteName = "Warcraft Wiki source summary", url = "https://warcraft.wiki.gg/wiki/Loaded_Gnomish_Dice" },
            { siteName = "Warcraft Wiki toys by source", url = "https://warcraft.wiki.gg/wiki/List_of_toys_by_source" },
        },
    },
    CrashinThrashinRollerController = {
        name = "Crashin' Thrashin' Roller Controller",
        mapOptions = {
            {
                id = "ggt:toy:crashin-thrashin-roller-controller:drakum",
                mapID = 534,
                mapLabel = "Tanaan Jungle",
                label = "Drakum",
                location = "Destroyed Dark Portal",
                isRoute = false,
                density = "One named rare spawn",
                dropDifficulty = "Low, non-guaranteed toy chance from Drakum.",
                pins = { { x = 0.839, y = 0.432, label = "Drakum - Roller Controller" } },
            },
        },
        summary = "Crashin' Thrashin' Roller Controller drops from Drakum near the destroyed Dark Portal in Tanaan Jungle. It is a permanent rare drop, not restricted to Winter Veil.",
        guide = {
            label = "Tanaan rare camp",
            requirement = "Reach the far eastern Tanaan Jungle Dark Portal area and find Drakum at the marked point.",
            action = "Kill and loot Drakum at 83.9,43.2, then return on another eligible character or after the relevant loot reset if the toy does not drop.",
            tips = {
                "The toy is not guaranteed; Wowhead comments document many kills without a drop.",
                "Older comments report a short roughly 5-7 minute respawn, but repeat loot eligibility may still be limited by the rare's daily quest flag.",
                "The controller is bind-on-use and can be traded or bought on the Auction House.",
                "Despite its Iron Armada and holiday associations, comments confirm this rare's toy can drop outside Winter Veil.",
            },
        },
        details = { "Drakum's documented coordinate is 83.9,43.2 in Tanaan Jungle." },
        sourceUrls = {
            { siteName = "Wowhead item and comments", url = "https://www.wowhead.com/item=108631/crashin-thrashin-roller-controller" },
            { siteName = "Wowhead Iron Armada comments", url = "https://www.wowhead.com/achievement=10353/iron-armada" },
            { siteName = "Independent rare guide", url = "https://fileunderferal.wordpress.com/2015/10/28/soloing-patch-6-2-2-rares-as-a-feral-druid/" },
        },
    },
    CrashinThrashinCannonController = {
        name = "Crashin' Thrashin' Cannon Controller",
        mapOptions = {
            {
                id = "ggt:toy:crashin-thrashin-cannon-controller:gondar",
                mapID = 534,
                mapLabel = "Tanaan Jungle",
                label = "Gondar",
                location = "Destroyed Dark Portal",
                isRoute = false,
                density = "One named rare spawn",
                dropDifficulty = "Low, non-guaranteed toy chance from Gondar.",
                pins = { { x = 0.807, y = 0.561, label = "Gondar - Cannon Controller" } },
            },
        },
        summary = "Crashin' Thrashin' Cannon Controller drops from Gondar near the destroyed Dark Portal in Tanaan Jungle. It remains available outside Winter Veil.",
        guide = {
            label = "Tanaan rare camp",
            requirement = "Reach the far eastern Tanaan Jungle Dark Portal area and find Gondar at the marked point.",
            action = "Kill and loot Gondar at 80.7,56.1, then use another eligible character or a later loot reset for additional chances.",
            tips = {
                "The toy is not guaranteed, and comments report dry streaks lasting dozens of kills.",
                "Nearby hostile packs can be cleared before Gondar so they do not complicate the pull on lower-level characters.",
                "The controller is bind-on-use and can be traded or bought on the Auction House.",
                "Current comment evidence contradicts early claims that the drop requires Winter Veil.",
            },
        },
        details = { "Gondar's documented coordinate is 80.7,56.1 in Tanaan Jungle." },
        sourceUrls = {
            { siteName = "Wowhead item and comments", url = "https://www.wowhead.com/item=108633/crashin-thrashin-cannon-controller" },
            { siteName = "Wowhead Gondar comments", url = "https://www.wowhead.com/npc=98284/gondar" },
            { siteName = "Wowhead hidden-secrets guide", url = "https://www.wowhead.com/guide/hidden-secrets-of-warlords-of-draenor-6150" },
        },
    },
    CrashinThrashinMortarController = {
        name = "Crashin' Thrashin' Mortar Controller",
        mapOptions = {
            {
                id = "ggt:toy:crashin-thrashin-mortar-controller:smashum-grabb",
                mapID = 534,
                mapLabel = "Tanaan Jungle",
                label = "Smashum Grabb",
                location = "Blood altar east of the destroyed Dark Portal",
                isRoute = false,
                density = "One named rare spawn",
                dropDifficulty = "Low, non-guaranteed toy chance from Smashum Grabb.",
                pins = { { x = 0.875, y = 0.561, label = "Smashum Grabb - Mortar Controller" } },
            },
        },
        summary = "Crashin' Thrashin' Mortar Controller drops from Smashum Grabb at the blood altar east of the destroyed Dark Portal in Tanaan Jungle. It is not a seasonal-only drop.",
        guide = {
            label = "Tanaan rare camp",
            requirement = "Reach the far eastern Tanaan Jungle Dark Portal area and find Smashum Grabb at the marked altar.",
            action = "Kill and loot Smashum Grabb at 87.5,56.1, then use another eligible character or a later loot reset for more chances.",
            tips = {
                "The controller is not guaranteed even when the rare is eligible to be looted.",
                "The blood altar is east of the destroyed Dark Portal and can be reached quickly while checking Drakum and Gondar on the same trip.",
                "The controller is bind-on-use and can be traded or bought on the Auction House.",
                "Wowhead comments confirm the drop outside Winter Veil and describe the rare as a once-per-day loot opportunity per character.",
            },
        },
        details = { "Smashum Grabb's documented coordinate is 87.5,56.1 in Tanaan Jungle." },
        sourceUrls = {
            { siteName = "Wowhead item and drop data", url = "https://www.wowhead.com/item=108634/crashin-thrashin-mortar-controller" },
            { siteName = "Wowhead NPC comments", url = "https://www.wowhead.com/npc=98285/smashum-grabb" },
            { siteName = "Warcraft Wiki NPC summary", url = "https://warcraft.wiki.gg/wiki/Smashum_Grabb" },
        },
    },
    BigRedRayGun = {
        name = "Big Red Raygun",
        mapOptions = {
            {
                id = "ggt:toy:big-red-raygun:doctor-weavil",
                mapID = 70,
                mapLabel = "Dustwallow Marsh",
                label = "Doctor Weavil",
                location = "Alcaz Island",
                isRoute = false,
                density = "One named elite inside the largest house",
                dropDifficulty = "Non-guaranteed drop from Doctor Weavil.",
                pins = { { x = 0.778, y = 0.174, label = "Doctor Weavil - upper floor" } },
            },
        },
        summary = "Big Red Raygun drops from Doctor Weavil on Alcaz Island. He is on the upper floor of the largest house in the island compound, so the pin marks the building rather than the shoreline.",
        guide = {
            label = "Named elite camp",
            requirement = "Travel to Alcaz Island off northeastern Dustwallow Marsh and enter the largest house at the marked compound.",
            action = "Climb to the upper floor, kill Doctor Weavil, and loot him for a chance at the Big Red Raygun.",
            tips = {
                "Doctor Weavil is inside the building at roughly 77.8,17.4, not outdoors at the map pin.",
                "Interrupt Mind Shatter when practical; current source notes say his old mind-control mechanic is no longer active.",
                "Clear or avoid the nearby guards before engaging so respawns and extra pulls do not prolong the attempt.",
                "One guide obtained the toy after about a dozen kills, but that is an anecdote rather than a guaranteed rate.",
            },
        },
        details = {
            "Doctor Weavil is an elite undead gnome on the top floor of the largest Alcaz Island house.",
            "The exterior map coordinate is approximately 77.8,17.4 in Dustwallow Marsh.",
        },
        sourceUrls = {
            { siteName = "Wowhead item and comments", url = "https://www.wowhead.com/item=142265/big-red-raygun" },
            { siteName = "Wowhead Alcaz Island guide", url = "https://www.wowhead.com/guide/alcaz-island-doctor-weavil-and-taming-mechano-spiders-in-7-1-4820" },
            { siteName = "Warcraft Wiki Doctor Weavil", url = "https://warcraft.wiki.gg/wiki/Doctor_Weavil" },
        },
    },
}

local farms = {}
local toyRows = NS.WITDropsData and NS.WITDropsData.categories and NS.WITDropsData.categories.toys or {}
for _, row in ipairs(toyRows) do
    local research = researchByFarmID[row.farmID]
    if research then
        local mapIDs = {}
        local mapNames = {}
        for _, option in ipairs(research.mapOptions or {}) do
            mapIDs[#mapIDs + 1] = option.mapID
            mapNames[#mapNames + 1] = option.mapLabel
        end
        farms[#farms + 1] = {
            id = "ggt:toy:" .. tostring(row.farmID):lower():gsub("[^%w]+", "-"),
            sourceType = "curated",
            sourceDataset = "GGTToyFarmData",
            sourceCategory = "toys",
            sourcePath = "Drops > Toys",
            activity = "toy",
            name = research.name or row.farmName,
            expansion = row.expansionLabel or row.expansion or "Unknown expansion",
            primaryItemID = tonumber(row.itemID),
            sourceRecordID = row.recordID,
            providerFarmID = row.farmID,
            routeCount = #research.mapOptions,
            mapIDs = mapIDs,
            mapNames = mapNames,
            targets = {},
            summary = research.summary,
            guide = research.guide,
            details = research.details,
            sourceUrls = research.sourceUrls,
            mapOptions = research.mapOptions,
        }
    end
end

local catalog = NS.FarmCatalog
if type(catalog) ~= "table" then
    catalog = { farms = {}, byID = {}, indexes = {}, sourceCounts = {} }
    NS.FarmCatalog = catalog
end
catalog.farms = type(catalog.farms) == "table" and catalog.farms or {}
catalog.byID = type(catalog.byID) == "table" and catalog.byID or {}
catalog.indexes = type(catalog.indexes) == "table" and catalog.indexes or {}
catalog.sourceCounts = type(catalog.sourceCounts) == "table" and catalog.sourceCounts or {}

local function AddIndex(indexName, key, position)
    if key == nil then return end
    catalog.indexes[indexName] = type(catalog.indexes[indexName]) == "table" and catalog.indexes[indexName] or {}
    local entries = catalog.indexes[indexName][key]
    if type(entries) ~= "table" then
        entries = {}
        catalog.indexes[indexName][key] = entries
    end
    entries[#entries + 1] = position
end

local uniqueItemsAdded = 0
for _, farm in ipairs(farms) do
    if not catalog.byID[farm.id] then
        local itemIndex = farm.primaryItemID and catalog.indexes.byItemID
        local isNewItem = farm.primaryItemID and (type(itemIndex) ~= "table" or type(itemIndex[farm.primaryItemID]) ~= "table")
        local position = #catalog.farms + 1
        catalog.farms[position] = farm
        catalog.byID[farm.id] = position
        AddIndex("byItemID", farm.primaryItemID, position)
        AddIndex("byRecordID", farm.sourceRecordID, position)
        AddIndex("byActivity", farm.activity, position)
        AddIndex("byExpansion", farm.expansion, position)
        AddIndex("bySourceCategory", farm.sourceCategory, position)
        AddIndex("bySourceType", farm.sourceType, position)
        for _, mapID in ipairs(farm.mapIDs or {}) do AddIndex("byMapID", mapID, position) end
        if isNewItem then uniqueItemsAdded = uniqueItemsAdded + 1 end
    end
end

catalog.farmCount = #catalog.farms
catalog.uniqueItemCount = (tonumber(catalog.uniqueItemCount) or 0) + uniqueItemsAdded
catalog.sourceCounts.curatedToys = #farms

NS.ToyFarmData = {
    dataVersion = 1,
    researchedAt = "2026-10-03",
    sourceRowCount = #toyRows,
    farms = farms,
}
