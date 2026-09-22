local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function EntranceSpot(id, mapName, location, x, y, zoneID, difficulty)
    return {
        id = id,
        source = "Retail Wowhead instance and item-source pages",
        sourceUrls = {
            "https://www.wowhead.com/zone=" .. tostring(zoneID),
        },
        mapName = mapName,
        location = location,
        routeType = "instance-entrance",
        density = "Instanced source",
        dropDifficulty = difficulty,
        tips = {
            "The overlay pin marks the outdoor entrance; instance-interior coordinates cannot be projected onto the zone map.",
            "Legacy instance lockouts and difficulty availability control how often this route can be repeated.",
        },
        coords = { C(x, y, location .. " entrance") },
        confidence = "high",
    }
end

local CLAM_SPOTS = {
    {
        id = "darkwater-clam-winterfin-retreat",
        source = "Retail Wowhead Darkwater Clam fishing and drop reports",
        sourceUrls = { ItemUrl(36781) },
        mapName = "Borean Tundra",
        location = "Winterfin Retreat shoreline and murloc village",
        routeType = "shore-fishing-and-mob-loop",
        density = "Compact mixed-source route",
        dropDifficulty = "Fish the open coast or clear Winterfin murlocs; both can yield Darkwater Clams.",
        tips = {
            "Alternate shoreline casts with the nearby Winterfin packs when one source feels slow.",
            "Open the clams for Succulent Clam Meat, Northsea Pearls, and the much rarer Siren's Tear.",
        },
        coords = {
            C(0.432, 0.139, "Winterfin shoreline"),
            C(0.414, 0.166, "Winterfin murloc loop"),
            C(0.455, 0.183, "Glimmer Bay fishing edge"),
        },
        confidence = "high",
    },
    {
        id = "darkwater-clam-moaki-harbor",
        source = "Retail Wowhead Darkwater Clam fishing reports",
        sourceUrls = { ItemUrl(36781) },
        mapName = "Dragonblight",
        location = "Moa'ki Harbor and southern Frozen Sea coast",
        routeType = "open-water-fishing",
        density = "Reliable coastal fishing",
        dropDifficulty = "Random Northrend open-water catch rather than a dedicated pool.",
        tips = {
            "Fish from the harbor and continue east along the coast if you want a moving route.",
            "The clam outcomes, not the ordinary ocean fish, are the high-variance part of this farm.",
        },
        coords = {
            C(0.487, 0.758, "Moa'ki Harbor dock"),
            C(0.558, 0.774, "Eastern Frozen Sea coast"),
            C(0.422, 0.739, "Western Frozen Sea coast"),
        },
        confidence = "high",
    },
    {
        id = "darkwater-clam-sholazar-gorlocs",
        source = "Retail Wowhead Darkwater Clam creature-drop reports",
        sourceUrls = { ItemUrl(36781) },
        mapName = "Sholazar Basin",
        location = "Gorloc packs west of Mosslight Pillar",
        routeType = "mob-density-route",
        density = "Dense gorloc camps",
        dropDifficulty = "The clam is an uncommon creature drop; fast area damage improves attempts.",
        tips = {
            "Sweep the waterside gorloc camps rather than waiting in one pocket.",
            "This is the best non-fishing alternative in the clam chain.",
        },
        coords = {
            C(0.314, 0.746, "Western gorloc camp"),
            C(0.344, 0.706, "Central gorloc packs"),
            C(0.364, 0.761, "Southern gorloc packs"),
        },
        confidence = "medium",
    },
    {
        id = "giant-darkwater-clam-wintergrasp",
        source = "Retail Wowhead Giant Darkwater Clam fishing locations",
        sourceUrls = { ItemUrl(45909) },
        mapName = "Wintergrasp",
        location = "Wintergrasp open water",
        routeType = "open-water-fishing",
        density = "Low-rate special catch",
        dropDifficulty = "Giant Darkwater Clam is a low-frequency Wintergrasp catch, but each shell contains several clam meats and can contain pearls.",
        tips = {
            "Use any safe open-water edge; the pins are access points, not fixed pools.",
            "Open every shell because the Northsea Pearl and Siren's Tear rolls are the valuable outcomes.",
        },
        coords = {
            C(0.505, 0.188, "Northern lake edge"),
            C(0.669, 0.515, "Eastern water access"),
            C(0.360, 0.528, "Western water access"),
        },
        confidence = "high",
    },
}

local function RegisterClamResult(itemID, itemName, category, professions, summary)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = professions,
        category = category,
        researchStatus = "researched",
        sourceUrls = {
            ItemUrl(itemID),
            ItemUrl(36781),
            ItemUrl(45909),
            "https://warcraft.wiki.gg/wiki/Siren%27s_Tear",
        },
        summary = summary,
        spots = CLAM_SPOTS,
    })
end

RegisterClamResult(36781, "Darkwater Clam", "Openable", { "fishing", "miscellaneous" }, "Tradeable openable shell from Northrend fishing and aquatic creatures. It contains Succulent Clam Meat and can also contain Northsea Pearl or the rare Siren's Tear.")
RegisterClamResult(45909, "Giant Darkwater Clam", "Openable", { "fishing", "miscellaneous" }, "Wintergrasp's larger openable clam contains several Succulent Clam Meats and can also yield Northsea Pearl or Siren's Tear.")
RegisterClamResult(36783, "Northsea Pearl", "Pearl", { "jewelcrafting", "miscellaneous" }, "Northsea Pearl is an uncommon result from opening Northrend Darkwater Clams; the marked routes therefore follow clam sources rather than direct pearl drops.")
RegisterClamResult(36784, "Siren's Tear", "Pearl", { "jewelcrafting", "tailoring", "miscellaneous" }, "Siren's Tear is the rare premium result from Darkwater Clams and Giant Darkwater Clams, used in several legacy profession recipes.")

local LUMBER_URLS = {
    ItemUrl(251762),
    "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
}

Register({
    itemID = 251762,
    itemName = "Coldwind Lumber",
    expansion = "wrath",
    professions = { "miscellaneous" },
    category = "Housing Lumber",
    researchStatus = "researched",
    sourceUrls = LUMBER_URLS,
    summary = "Warband-bound Northrend housing lumber. It is not auctionable itself, but it is the shared harvesting input for Northrend profession decor that can be sold on the Auction House.",
    spots = {
        {
            id = "coldwind-lumber-grizzly-hills",
            source = "Retail Coldwind Lumber description and dynamic housing-lumber route research",
            sourceUrls = LUMBER_URLS,
            mapName = "Grizzly Hills",
            location = "Zone-wide forest and riverbank circuit",
            routeType = "dynamic-lumber-route",
            density = "High dynamic-node potential",
            dropDifficulty = "Requires the housing harvesting tutorial and a Harvesting Hatchet; lumber nodes are dynamic.",
            tips = { "Follow the forested perimeter and riverbanks.", "Treat pins as route anchors rather than guaranteed node spawns." },
            coords = { C(0.218, 0.343, "Northwest forest"), C(0.350, 0.222, "Northern forest"), C(0.612, 0.246, "Northeast forest"), C(0.786, 0.431, "Eastern forest"), C(0.684, 0.704, "Southeast forest"), C(0.430, 0.775, "Southern forest"), C(0.205, 0.620, "Western forest") },
            confidence = "medium",
        },
        {
            id = "coldwind-lumber-sholazar-basin",
            source = "Retail Coldwind Lumber description and dynamic housing-lumber route research",
            sourceUrls = LUMBER_URLS,
            mapName = "Sholazar Basin",
            location = "Basin tree-line circuit",
            routeType = "dynamic-lumber-route",
            density = "High dynamic-node potential",
            dropDifficulty = "Requires a Harvesting Hatchet; the basin's dense vegetation makes a compact flying circuit.",
            tips = { "Circle each pillar and the outer tree line.", "Treat pins as route anchors rather than guaranteed node spawns." },
            coords = { C(0.235, 0.405, "Western tree line"), C(0.330, 0.215, "Northwest canopy"), C(0.565, 0.205, "Northern canopy"), C(0.770, 0.405, "Eastern tree line"), C(0.695, 0.710, "Southeast canopy"), C(0.425, 0.795, "Southern canopy"), C(0.310, 0.585, "River's Heart west") },
            confidence = "medium",
        },
        {
            id = "coldwind-lumber-howling-fjord",
            source = "Retail Coldwind Lumber description and dynamic housing-lumber route research",
            sourceUrls = LUMBER_URLS,
            mapName = "Howling Fjord",
            location = "Wooded plateau and coast circuit",
            routeType = "dynamic-lumber-route",
            density = "Broad dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet and benefits greatly from flying.",
            tips = { "Keep to wooded plateaus and avoid long crossings over the central inlet." },
            coords = { C(0.245, 0.255, "Northwest woods"), C(0.445, 0.220, "Northern plateau"), C(0.680, 0.270, "Northeast woods"), C(0.755, 0.555, "Eastern woods"), C(0.565, 0.760, "Southern woods"), C(0.285, 0.700, "Southwest woods") },
            confidence = "medium",
        },
        {
            id = "coldwind-lumber-dragonblight",
            source = "Retail Coldwind Lumber description and dynamic housing-lumber route research",
            sourceUrls = LUMBER_URLS,
            mapName = "Dragonblight",
            location = "West and east woodland belts",
            routeType = "dynamic-lumber-route",
            density = "Mixed dynamic-node route",
            dropDifficulty = "Requires a Harvesting Hatchet; barren central terrain lowers node density.",
            tips = { "Prioritize the west and east woodland belts instead of crossing the central wastes repeatedly." },
            coords = { C(0.170, 0.410, "West woodland"), C(0.280, 0.270, "Northwest woodland"), C(0.690, 0.285, "Northeast woodland"), C(0.820, 0.485, "Eastern woodland"), C(0.720, 0.690, "Southeast woodland"), C(0.300, 0.690, "Southwest woodland") },
            confidence = "medium",
        },
    },
})

local function RegisterInstanceMaterial(itemID, itemName, category, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "wrath",
        professions = { "miscellaneous" },
        category = category,
        researchStatus = "researched",
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = spots,
    })
end

RegisterInstanceMaterial(43102, "Frozen Orb", "Dungeon Reagent", "Frozen Orb is the first-tier Wrath orb used by many profession recipes and the Icecrown Plague Canister housing recipe. Target final bosses in Northrend heroic dungeons.", {
    EntranceSpot("frozen-orb-utgarde-pinnacle", "Howling Fjord", "Utgarde Pinnacle", 0.573, 0.467, 1196, "Farm the final heroic-dungeon boss; the orb is a legacy end-boss reagent."),
    EntranceSpot("frozen-orb-gundrak", "Zul'Drak", "Gundrak", 0.762, 0.211, 4416, "Farm the final heroic-dungeon boss; the orb is a legacy end-boss reagent."),
    EntranceSpot("frozen-orb-halls-lightning", "The Storm Peaks", "Halls of Lightning", 0.454, 0.214, 4272, "Farm the final heroic-dungeon boss; the orb is a legacy end-boss reagent."),
})

RegisterInstanceMaterial(45087, "Runed Orb", "Raid Reagent", "Runed Orb is Ulduar's tradeable profession reagent and now also feeds Northrend blacksmithing housing decor.", {
    EntranceSpot("runed-orb-ulduar", "The Storm Peaks", "Ulduar", 0.416, 0.178, 4273, "Legacy raid bosses are the direct farm; raid lockouts limit repeatability."),
})

RegisterInstanceMaterial(47556, "Crusader Orb", "Raid Reagent", "Crusader Orb is the Trial of the Crusader-era crafting reagent used in item-level 245 profession recipes.", {
    EntranceSpot("crusader-orb-trial-crusader", "Icecrown", "Trial of the Crusader", 0.750, 0.218, 4722, "Legacy raid bosses are the direct farm; raid lockouts limit repeatability."),
})

RegisterInstanceMaterial(49908, "Primordial Saronite", "Raid Reagent", "Primordial Saronite is Icecrown Citadel's tradeable crafting reagent, used by end-of-expansion profession recipes and the Shadowmourne quest chain.", {
    EntranceSpot("primordial-saronite-icecrown-citadel", "Icecrown", "Icecrown Citadel", 0.536, 0.863, 4812, "Legacy raid bosses are the direct farm; raid lockouts limit repeatability."),
})

Register({
    itemID = 42780,
    itemName = "Relic of Ulduar",
    expansion = "wrath",
    professions = { "miscellaneous" },
    category = "Reputation",
    researchStatus = "researched",
    sourceUrls = { ItemUrl(42780), "https://warcraft.wiki.gg/wiki/Relic_of_Ulduar" },
    summary = "Tradeable Sons of Hodir reputation turn-in dropped by many Storm Peaks creatures. Dense frost-vrykul and elemental camps make it a useful side product farm.",
    spots = {
        {
            id = "relic-ulduar-storm-peaks-circuit",
            source = "Retail item sources and long-running Storm Peaks farming reports",
            sourceUrls = { ItemUrl(42780) },
            mapName = "The Storm Peaks",
            location = "Valkyrion, Brunnhildar, and Fjorn's Anvil camp circuit",
            routeType = "mob-density-route",
            density = "Several dense camps",
            dropDifficulty = "Broad creature drop; clear complete camps and value Frostweave and elemental side drops.",
            tips = { "Rotate camps if respawns lag.", "The southeast Fjorn's Anvil area overlaps elemental farming." },
            coords = { C(0.240, 0.620, "Valkyrion"), C(0.480, 0.700, "Brunnhildar Village outskirts"), C(0.680, 0.480, "Eastern frost-vrykul packs"), C(0.760, 0.640, "Fjorn's Anvil") },
            confidence = "medium",
        },
    },
})

Register({
    itemID = 45912,
    itemName = "Book of Glyph Mastery",
    expansion = "wrath",
    professions = { "inscription", "miscellaneous" },
    category = "Recipe Discovery",
    researchStatus = "researched",
    sourceUrls = { ItemUrl(45912) },
    summary = "Tradeable rare world drop that teaches one of the Northrend inscription glyph discoveries. There is no guaranteed source, so dense level-appropriate mob loops maximize attempts.",
    spots = {
        {
            id = "book-glyph-mastery-sholazar-avalanche",
            source = "Retail item page and historical high-signal Sholazar farming reports",
            sourceUrls = { ItemUrl(45912), "https://www.wowhead.com/zone=3711/sholazar-basin" },
            mapName = "Sholazar Basin",
            location = "The Avalanche and eastern cultist packs",
            routeType = "rare-world-drop-loop",
            density = "Dense mobs, very low target rate",
            dropDifficulty = "Rare Northrend-wide world drop; the route increases attempts but cannot guarantee the book.",
            tips = { "Loop the packs around /way 66 51.", "Treat Frostweave, greens, and other world drops as the dependable value." },
            coords = { C(0.660, 0.510, "The Avalanche farm anchor"), C(0.637, 0.482, "Northern pack"), C(0.688, 0.535, "Southern pack") },
            confidence = "medium",
        },
        {
            id = "book-glyph-mastery-icecrown-humanoids",
            source = "Retail item page and Northrend world-drop reports",
            sourceUrls = { ItemUrl(45912), "https://www.wowhead.com/zone=210/icecrown" },
            mapName = "Icecrown",
            location = "Ymirheim and Onslaught Harbor humanoid loops",
            routeType = "rare-world-drop-cloth-loop",
            density = "High mobs, very low target rate",
            dropDifficulty = "Rare world drop; use the route for volume and side loot rather than a promised drop rate.",
            tips = { "This overlaps the established Frostweave and Damaged Necklace loops." },
            coords = { C(0.548, 0.570, "Ymirheim circuit"), C(0.592, 0.584, "Eastern Ymirheim packs"), C(0.086, 0.456, "Onslaught Harbor packs") },
            confidence = "medium",
        },
    },
})
