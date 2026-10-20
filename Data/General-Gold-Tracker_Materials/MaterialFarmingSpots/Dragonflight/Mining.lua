local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local WAKING_SHORES_DRACONIUM_ROUTE = {
    id = "dragonflight-waking-shores-obsidian-ore-route",
    mapID = 2022,
    source = "Artisans of Azeroth Draconium route, Wowhead Dragonflight mining overview, Wowhead ore item/object pages, Warcraft Wiki, WoWDB",
    sourceUrls = {
        "https://artisansofazeroth.com/where-to-farm-draconium-wow-dragonflight-gold-making-guide/",
        "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=190396/serevite-ore",
        "https://www.wowhead.com/object=379252/draconium-deposit",
        "https://warcraft.wiki.gg/wiki/Draconium_Ore",
        "https://www.wowdb.com/items/189143-draconium-ore",
        "https://warcraft.wiki.gg/wiki/Khaz%27gorite_Ore",
        "https://www.wowdb.com/items/190312-khazgorite-ore",
    },
    mapName = "The Waking Shores",
    location = "Obsidian Citadel and southwest lava ridges",
    routeType = "mining-loop",
    density = "Medium to high",
    dropDifficulty = "Serevite is common, Draconium is the target ore, and Khaz'gorite is a rare side gather from Serevite or Draconium nodes.",
    tips = {
        "Clear all nearby Serevite and Draconium nodes because rare ore depends on respawn rolls.",
        "Favor rocky lava ridges and cliff edges around the Obsidian Citadel.",
        "Elemental mining modifiers can add Rousing Earth, Fire, Frost, or Order while routing.",
    },
    coords = {
        C(0.3054, 0.6863, "Obsidian Citadel west ore"),
        C(0.3316, 0.5861, "Obsidian Citadel north bend"),
        C(0.3596, 0.4846, "Life-Binder route north"),
        C(0.4310, 0.5454, "Central lava ridge"),
        C(0.4544, 0.5806, "Eastern lava ridge"),
        C(0.4024, 0.6546, "South ridge return"),
        C(0.3495, 0.6800, "Southwest return"),
        C(0.3962, 0.7746, "South coast ore"),
        C(0.2380, 0.7708, "Obsidian approach"),
    },
    confidence = "high",
}

local OHNAHRAN_HERB_ORE_ROUTE = {
    id = "dragonflight-ohnahran-plains-herb-ore-route",
    mapID = 2023,
    source = "Artisans of Azeroth Ohn'ahran herb and ore route plus Wowhead mining overview",
    sourceUrls = {
        "https://artisansofazeroth.com/ohnahran-plains-herb-and-ore-route-wow-dragonflight-gold-guide/",
        "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight",
        "https://www.wowhead.com/item=190396/serevite-ore",
        "https://www.wowhead.com/object=379252/draconium-deposit",
        "https://warcraft.wiki.gg/wiki/Khaz%27gorite_Ore",
        "https://www.wowdb.com/items/190312-khazgorite-ore",
    },
    mapName = "Ohn'ahran Plains",
    location = "Northeast ridge into south river sweep and Maruukai return",
    routeType = "dual-gathering-loop",
    density = "Medium",
    dropDifficulty = "Good mixed ore and herb path. Serevite is common, Draconium appears along rocky sections, and Khaz'gorite is rare.",
    tips = {
        "Use this as a dual-gathering loop when ore and herb values are both relevant.",
        "Keep to ridge lines and river bends where node density is more consistent.",
        "Mine all ore nodes while hunting Khaz'gorite because it is a rare side gather.",
    },
    coords = {
        C(0.7510, 0.3814, "Northeast ridge start"),
        C(0.7817, 0.4423, "Northeast ridge turn"),
        C(0.7448, 0.5020, "Eastern river ridge"),
        C(0.7243, 0.5665, "Southeast slope"),
        C(0.6768, 0.6147, "South river bend"),
        C(0.6311, 0.7116, "Southern plains node"),
        C(0.5558, 0.7465, "Southwest sweep"),
        C(0.5192, 0.5490, "Central return"),
        C(0.6026, 0.4892, "Maruukai ridge"),
        C(0.7040, 0.4344, "Northeast return"),
    },
    confidence = "high",
}

-- Supplied Retail Routes geometry, decoded without changing vertex order.
-- Khaz'gorite candidates reuse ore circuits for rare side gathers, not dedicated deposits.
local function SuppliedOreRoute(id, sortOrder, mapID, mapName, location, routeOrigin, source, packedCoords, tips, sourceUrls, rareSideGather)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    table.insert(tips, 1, "Supplied route provenance: " .. source)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeType = "mining-loop",
        routeOrigin = routeOrigin,
        source = source,
        sourceUrls = sourceUrls,
        tips = tips,
        coords = coords,
        dropDifficulty = rareSideGather
            and "Khaz'gorite is a rare side gather from Serevite and Draconium deposits; prioritize Draconium on this circuit."
            or "Follow rocky terrain and cliff ledges; route vertices are travel anchors, not guaranteed deposit spawns.",
        confidence = "medium",
        inGameTested = false,
        isRoute = true,
    }
end

local SUPPLIED_ORE_ROUTES = {
    ["Serevite Ore"] = {
        SuppliedOreRoute(
            "dragonflight-serevite-ore-2022-1-supplied", 1,
            2022, "The Waking Shores", "Main route - The Waking Shores",
            "published", "Published GoldGoblin long Waking Shores ore circuit, supplied for Serevite. Attachment vertex key 13 at position 53 was restored to 53 against the published GoldGoblin Waking Shores route; coordinates are unchanged.",
            {
                47464557, 46664202, 47133841, 50053526, 53573425, 55453576, 57813690, 59093762,
                59883939, 61394113, 62214515, 65414320, 68463989, 70943806, 73603509, 73702907,
                77072421, 79332670, 79512949, 79683228, 78493481, 77303735, 76364230, 78014649,
                76114967, 72704743, 69215058, 68135595, 68956012, 70636619, 68906983, 65387192,
                62347294, 59817599, 58118072, 55578152, 52658101, 49547883, 46557770, 44027853,
                43138224, 41228367, 39228220, 36108001, 33427535, 29597530, 26677381, 28357042,
                28046626, 28006239, 31265828, 32615353, 34074981, 37474852, 39265222, 42335533,
                44745346, 45964949,
            },
            {
                "Follow the cliff faces and rocky outcrops rather than cutting straight across open ground.",
                "The southern/coastal rocky sections are particularly useful for Serevite density.",
                "Mine ordinary Serevite nodes rather than permanently skipping them. Normal Serevite occupies a mining-node spawn and clearing it gives the node pool a chance to respawn as Draconium or a modified deposit.",
                "Take Rich, Hardened, Molten, Primal and Titan-Touched variants whenever they appear.",
                "This long circuit is useful when competition is low. If you repeatedly see freshly mined nodes, reverse the route.",
            },
            {
                "https://thewowdb.com/farm/serevite-ore-190395/?utm_source=chatgpt.com",
                "https://www.goldgoblin.net/farmspots/sereviterz-farmen/",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
        SuppliedOreRoute(
            "dragonflight-serevite-ore-2023-2-supplied", 2,
            2023, "Ohn'ahran Plains", "Alternative 1 - Ohn'ahran Plains long circuit",
            "published", "Published GoldGoblin long Ohn'ahran Serevite circuit; retained separately from its short and medium variants.",
            {
                62611702, 65181881, 66012758, 67903057, 70633225, 74172895, 76792529, 78932169,
                82292065, 85192426, 85982874, 85033298, 80903402, 78903803, 78584249, 80704497,
                83544538, 85274719, 84404997, 83305183, 78605191, 75005677, 72626224, 70756566,
                66876687, 63386300, 62246039, 59425975, 57256285, 56406714, 57547052, 57617338,
                56287577, 53297658, 51977459, 52047060, 52226756, 51176642, 49796632, 46716744,
                43236514, 39406607, 37536867, 35606983, 33546939, 31386543, 34136021, 36015698,
                38685326, 41605232, 43505013, 43664722, 40754522, 38804320, 35814255, 33464085,
                32983840, 33593612, 35303431, 37523396, 39843522, 41943748, 43793583, 48113507,
                49783180, 51522886, 53823004, 56483117, 58462910, 59842339, 60271999,
            },
            {
                "Concentrate on the hillier northern/eastern edges rather than the flat center.",
                "Ohn'ahran is less vertically demanding than Azure Span, so node-to-node travel can be efficient.",
                "Particularly useful if Waking Shores has another miner running immediately ahead of you.",
                "Don't ignore nearby Draconium nodes: both ores occupy the same general spawn system.",
            },
            {
                "https://www.goldgoblin.net/farmspots/sereviterz-farmen/",
                "https://thewowdb.com/farm/serevite-ore-190395/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
        SuppliedOreRoute(
            "dragonflight-serevite-ore-2024-3-supplied", 3,
            2024, "The Azure Span", "Alternative 2 - The Azure Span long circuit",
            "published", "Published GoldGoblin long Azure Span Serevite circuit.",
            {
                45095530, 40315087, 38374952, 31544607, 24084524, 20094746, 15274640, 15594406,
                18203857, 20553572, 24663203, 29713308, 39193212, 44372983, 49142819, 52863170,
                58132951, 62992494, 70022338, 77572658, 78703160, 78183661, 71693717, 67533757,
                65954080, 70004700, 71895252, 70995465, 69485968, 66895941, 65045463, 61264990,
                59984656, 57254662, 56305337, 58165779, 58666392, 57016645, 55156500, 53036500,
                49716382, 47416287, 45006079,
            },
            {
                "Strong choice for mixed gathering rather than maximum pure Serevite.",
                "Search rock walls whenever the route skirts mountains or steep terrain.",
                "Azure Span is particularly good if you also gather herbs while following the route.",
                "The longer loop reduces the chance of catching your own node respawn cycle.",
            },
            {
                "https://www.goldgoblin.net/farmspots/sereviterz-farmen/",
                "https://thewowdb.com/farm/serevite-ore-190395/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
    },
    ["Draconium Ore"] = {
        SuppliedOreRoute(
            "dragonflight-draconium-ore-2024-1-supplied", 1,
            2024, "The Azure Span", "Main route - The Azure Span, Draconium-focused long route",
            "published", "Published GoldGoblin Draconium-focused Azure Span mountain circuit; distinct from the Serevite Azure Span route.",
            {
                49992750, 62442846, 71122174, 80512386, 81493518, 69033819, 66234361, 71115436,
                66435879, 62455248, 58544615, 55325338, 56996047, 51836408, 44955667, 42934855,
                37444620, 24534843, 21634192, 30613346, 35262904,
            },
            {
                "Stay close to mountain slopes, cliffs and elevated rocky areas; Draconium tends to be more common in inconvenient/out-of-the-way locations.",
                "Don't fly at maximum altitude blindly. Most missed Draconium nodes are underneath the rider on cliff shelves.",
                "Rich/modified Draconium nodes should always take priority.",
                "This route is also my #1 Khaz'gorite route, because Draconium has the better Khaz'gorite side-gather chance.",
            },
            {
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://progameguides.com/wow/best-way-to-farm-draconium-ore-in-wow-dragonflight/?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
        SuppliedOreRoute(
            "dragonflight-draconium-ore-2025-2-supplied", 2,
            2025, "Thaldraszus", "Alternative 1 - Thaldraszus",
            "published", "Published GoldGoblin Thaldraszus Draconium circuit.",
            {
                54643967, 55773718, 55823490, 56033259, 56903092, 58452994, 60063014, 60673260,
                57733744, 57024398, 57265425, 57735857, 58456398, 59697046, 60107845, 59217992,
                57897999, 55807960, 55387797, 54907581, 55717341, 54847156, 54056689, 54016336,
                54565874, 52105884, 50695797, 48775540, 49335126, 50764824, 53124635,
            },
            {
                "Prioritize mountaintops, cliff ledges and floating islands.",
                "Thaldraszus contains a lot more vertical terrain, so don't waste Skyriding momentum dropping all the way to ground level for a lone low-value Serevite node.",
                "Look behind/under terrain shelves: Draconium can spawn in locations that aren't visible from a straight high-altitude pass.",
                "This is one of the better alternatives if Azure Span is being heavily farmed.",
            },
            {
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
                "https://progameguides.com/wow/best-way-to-farm-draconium-ore-in-wow-dragonflight/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
        SuppliedOreRoute(
            "dragonflight-draconium-ore-2022-3-supplied", 3,
            2022, "The Waking Shores", "Alternative 2 - The Waking Shores long circuit",
            "adapted", "Shared GoldGoblin long Waking Shores ore circuit, adapted for Draconium targeting; geometry matches the supplied Serevite Waking Shores circuit. Attachment vertex key 13 at position 53 was restored to 53 against the published GoldGoblin Waking Shores route; coordinates are unchanged.",
            {
                47464557, 46664202, 47133841, 50053526, 53573425, 55453576, 57813690, 59093762,
                59883939, 61394113, 62214515, 65414320, 68463989, 70943806, 73603509, 73702907,
                77072421, 79332670, 79512949, 79683228, 78493481, 77303735, 76364230, 78014649,
                76114967, 72704743, 69215058, 68135595, 68956012, 70636619, 68906983, 65387192,
                62347294, 59817599, 58118072, 55578152, 52658101, 49547883, 46557770, 44027853,
                43138224, 41228367, 39228220, 36108001, 33427535, 29597530, 26677381, 28357042,
                28046626, 28006239, 31265828, 32615353, 34074981, 37474852, 39265222, 42335533,
                44745346, 45964949,
            },
            {
                "Fly the mountain chains and valley walls rather than following roads.",
                "Waking Shores has enough terrain variation to produce both Serevite and Draconium in large numbers.",
                "The long route can effectively be broken into smaller northern/southern loops if node competition is high. Farming guides similarly recommend sticking to the zone's peaks and cliffs.",
                "Excellent fallback because you still collect substantial Serevite while targeting Draconium.",
            },
            {
                "https://www.goldgoblin.net/farmspots/sereviterz-farmen/",
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://progameguides.com/wow/best-way-to-farm-draconium-ore-in-wow-dragonflight/?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
            },
            false
        ),
    },
    ["Khaz'gorite Ore"] = {
        SuppliedOreRoute(
            "dragonflight-khaz-gorite-ore-2024-1-supplied", 1,
            2024, "The Azure Span", "Main route - The Azure Span Draconium route",
            "adapted", "Adapted from GoldGoblin's Draconium-focused Azure Span circuit for Khaz'gorite rare side gathers; no dedicated Khaz'gorite deposit is implied.",
            {
                49992750, 62442846, 71122174, 80512386, 81493518, 69033819, 66234361, 71115436,
                66435879, 62455248, 58544615, 55325338, 56996047, 51836408, 44955667, 42934855,
                37444620, 24534843, 21634192, 30613346, 35262904,
            },
            {
                "Treat this as a Draconium-per-hour optimization problem, not a Khaz'gorite spawn route.",
                "Prioritize Draconium Deposits and especially Rich/modified Draconium.",
                "More Draconium nodes = more rolls for Khaz'gorite.",
                "The Draconium specialization is particularly useful when your objective is Khaz'gorite; Wowhead specifically recommends focusing on Draconium over Serevite for this reason.",
                "Perception remains desirable because once Khaz'gorite is present it can increase the yield, although community testing suggested Perception may not determine the initial Khaz'gorite roll itself.",
            },
            {
                "https://www.wowhead.com/guide/professions/mining/specialization-builds-dragonflight?utm_source=chatgpt.com",
                "https://www.reddit.com/r/woweconomy/comments/103lg59/some_mining_stats/?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
            },
            true
        ),
        SuppliedOreRoute(
            "dragonflight-khaz-gorite-ore-2025-2-supplied", 2,
            2025, "Thaldraszus", "Alternative 1 - Thaldraszus",
            "adapted", "Adapted from GoldGoblin's Thaldraszus Draconium circuit for Khaz'gorite rare side gathers.",
            {
                54643967, 55773718, 55823490, 56033259, 56903092, 58452994, 60063014, 60673260,
                57733744, 57024398, 57265425, 57735857, 58456398, 59697046, 60107845, 59217992,
                57897999, 55807960, 55387797, 54907581, 55717341, 54847156, 54056689, 54016336,
                54565874, 52105884, 50695797, 48775540, 49335126, 50764824, 53124635,
            },
            {
                "Good choice for hard-to-reach Draconium, which is exactly the type of node you're interested in for Khaz'gorite.",
                "Check cliff ledges rather than just the mountain summit.",
                "Include floating islands when they don't cause excessive travel time.",
                "A high-perception mining tool is preferable when specifically farming the rare side-gather.",
            },
            {
                "https://www.wowhead.com/guide/professions/mining/specialization-builds-dragonflight?utm_source=chatgpt.com",
                "https://www.reddit.com/r/woweconomy/comments/103lg59/some_mining_stats/?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
            },
            true
        ),
        SuppliedOreRoute(
            "dragonflight-khaz-gorite-ore-2022-3-supplied", 3,
            2022, "The Waking Shores", "Alternative 2 - The Waking Shores",
            "adapted", "Adapted from GoldGoblin's long Waking Shores ore circuit for Khaz'gorite rare side gathers, prioritizing Draconium. Attachment vertex key 13 at position 53 was restored to 53 against the published GoldGoblin Waking Shores route; coordinates are unchanged.",
            {
                47464557, 46664202, 47133841, 50053526, 53573425, 55453576, 57813690, 59093762,
                59883939, 61394113, 62214515, 65414320, 68463989, 70943806, 73603509, 73702907,
                77072421, 79332670, 79512949, 79683228, 78493481, 77303735, 76364230, 78014649,
                76114967, 72704743, 69215058, 68135595, 68956012, 70636619, 68906983, 65387192,
                62347294, 59817599, 58118072, 55578152, 52658101, 49547883, 46557770, 44027853,
                43138224, 41228367, 39228220, 36108001, 33427535, 29597530, 26677381, 28357042,
                28046626, 28006239, 31265828, 32615353, 34074981, 37474852, 39265222, 42335533,
                44745346, 45964949,
            },
            {
                "Mine every Draconium node, regardless of whether it is normal or modified.",
                "Also mine modified Serevite nodes; Khaz'gorite can come from those as well.",
                "The mountainous Waking Shores layout produces many opportunities for Draconium while still keeping total nodes/hour high.",
                "Community gathering data also found considerably more Khaz'gorite associated with Draconium than Serevite, supporting the Draconium-first strategy.",
            },
            {
                "https://www.goldgoblin.net/farmspots/sereviterz-farmen/",
                "https://www.reddit.com/r/woweconomy/comments/103lg59/some_mining_stats/?utm_source=chatgpt.com",
                "https://www.wowhead.com/guide/professions/mining/specialization-builds-dragonflight?utm_source=chatgpt.com",
                "https://raw.githubusercontent.com/CallanWIT/Routes-Import-Export/master/RoutesImportExport.lua",
                "https://www.wowhead.com/guide/professions/mining/overview-leveling-dragonflight?utm_source=chatgpt.com",
                "https://www.goldgoblin.net/farmspots/drakoniumerz-farmen/",
            },
            true
        ),
    },
}

local function WithSuppliedRoutes(itemName)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_ORE_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs({ WAKING_SHORES_DRACONIUM_ROUTE, OHNAHRAN_HERB_ORE_ROUTE }) do
        spot.isRoute = true
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterOre(itemID, itemName, summary, qualityRank)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "dragonflight",
        professions = { "mining", "jewelcrafting" },
        category = "Ore",
        qualityRank = qualityRank,
        isRoute = true,
        sourceUrls = { ItemUrl(itemID) },
        summary = summary,
        spots = WithSuppliedRoutes(itemName),
    })
end

RegisterOre(190394, "Serevite Ore",
    "Common Dragonflight ore; start with the long Waking Shores circuit, with Ohn'ahran and Azure Span alternatives.", 1)
RegisterOre(190395, "Serevite Ore",
    "Common Dragonflight ore; start with the long Waking Shores circuit, with Ohn'ahran and Azure Span alternatives.", 2)
RegisterOre(190396, "Serevite Ore",
    "Common Dragonflight ore; start with the long Waking Shores circuit, with Ohn'ahran and Azure Span alternatives.", 3)
-- Draconium quality ranks: https://thewowdb.com/item/draconium-ore-189143/
RegisterOre(189143, "Draconium Ore",
    "Dragonflight ore; start with the dedicated Azure Span mountain circuit, with Thaldraszus and Waking Shores alternatives.", 1)
RegisterOre(188658, "Draconium Ore",
    "Dragonflight ore; start with the dedicated Azure Span mountain circuit, with Thaldraszus and Waking Shores alternatives.", 2)
RegisterOre(190311, "Draconium Ore",
    "Dragonflight ore; start with the dedicated Azure Span mountain circuit, with Thaldraszus and Waking Shores alternatives.", 3)
RegisterOre(190312, "Khaz'gorite Ore",
    "Rare side gather from Serevite and Draconium; prioritize Draconium on the Azure Span, Thaldraszus, or Waking Shores circuits.", 1)
RegisterOre(190313, "Khaz'gorite Ore",
    "Rare side gather from Serevite and Draconium; prioritize Draconium on the Azure Span, Thaldraszus, or Waking Shores circuits.", 2)
RegisterOre(190314, "Khaz'gorite Ore",
    "Rare side gather from Serevite and Draconium; prioritize Draconium on the Azure Span, Thaldraszus, or Waking Shores circuits.", 3)
