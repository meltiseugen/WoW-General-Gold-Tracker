local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Items = NS.MaterialFarmingSpots.items

-- Current binding, recipe evidence and exclusions: docs/research/legion-specialty-2026-10-19.*.
-- Random catches, recycling and rotating dig sites have no fabricated yields or spawn pins.
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end

local FISH_MAPS = {
    [124107] = 630, [124108] = 641, [124109] = 650,
    [124110] = 634, [124111] = 680, [124112] = 680,
}

local function FishingSpots(record)
    local spots = Copy((Items[record.cloneFrom] or {}).spots or {})
    for _, spot in ipairs(spots) do
        spot.id = spot.id .. "-specialty-" .. record.itemID
        spot.mapID = FISH_MAPS[record.cloneFrom]
        spot.isRoute = false
        spot.routeType = "fishing-source-pins"
        spot.source = "Existing sourced fishing-water anchors; item-specific bait or side-catch acquisition"
        spot.sourceUrls = Copy(record.sourceUrls)
        spot.tips = Copy(record.tips)
        spot.density = "Chance catch; no measured yield"
        spot.dropDifficulty = "The markers identify suitable fishing water, not guaranteed bait or rare-item catches."
        spot.confidence = "medium"
    end
    return spots
end

local function Pin(id, mapID, mapName, location, x, y, urls, tips, kind)
    return {
        id = "legion-specialty-" .. id,
        mapID = mapID, mapName = mapName, location = location,
        isRoute = false, routeType = kind or "mob-drop",
        source = "Curated source/comment location; scouting anchor, not a guaranteed individual drop",
        sourceUrls = Copy(urls), tips = Copy(tips),
        density = "Variable; no measured hourly yield",
        dropDifficulty = "Chance-based source; availability and competition vary.",
        confidence = "medium",
        coords = { { x = x, y = y, label = location } },
    }
end

local DISCOVERIES = {
    {
        itemID = 133701,
        name = "Skrog Toenail",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Azsuna waters for this bait. Its effect attracts a murloc after it expires.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133701",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 133702,
        name = "Aromatic Murloc Slime",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Use a Skrog Toenail, wait for its murloc to appear, then defeat and loot it for the slime.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133702",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 133703,
        name = "Pearlescent Conch",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Azsuna waters for the conch used to attract Nar'thalas Hermits.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133703",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 133704,
        name = "Rusty Queenfish Brooch",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Azsuna waters for the brooch; using it reveals Ghostly Queenfish schools.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133704",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 133705,
        name = "Rotten Fishbone",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Val'sharah waters for the bait used to catch Ancient Mossgill.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133705",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124108,
        auctionable = true,
    },
    {
        itemID = 133707,
        name = "Nightmare Nightcrawler",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Val'sharah waters for the bait used to catch Terrorfin.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133707",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124108,
        auctionable = true,
    },
    {
        itemID = 133708,
        name = "Drowned Thistleleaf",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Val'sharah waters for the bait used to catch Thorned Flounder.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133708",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124108,
        auctionable = true,
    },
    {
        itemID = 133709,
        name = "Funky Sea Snail",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Highmountain waters for the snail. Its expiring effect summons a Drogbar.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133709",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124109,
        auctionable = true,
    },
    {
        itemID = 133710,
        name = "Salmon Lure",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Use Funky Sea Snail and loot the attracted Drogbar for this lure; it is also listed in Highmountain fishing catches.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133710",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124109,
        auctionable = true,
    },
    {
        itemID = 133711,
        name = "Swollen Murloc Egg",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Highmountain waters for the egg used to attract Mountain Puffer.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133711",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124109,
        auctionable = true,
    },
    {
        itemID = 133712,
        name = "Frost Worm",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Highmountain waters for the worm used to catch Coldriver Carp.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133712",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124109,
        auctionable = true,
    },
    {
        itemID = 133713,
        name = "Moosehorn Hook",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Stormheim waters for this hook, then fish with its effect to obtain Silverscale Minnows.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133713",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124110,
        auctionable = true,
    },
    {
        itemID = 133714,
        name = "Silverscale Minnow",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish with Moosehorn Hook active in Stormheim to catch this second-stage bait for Thundering Stormray.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133714",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124110,
        auctionable = true,
    },
    {
        itemID = 133715,
        name = "Ancient Vrykul Ring",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Stormheim waters for the ring used to catch Oodelfjisk.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133715",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124110,
        auctionable = true,
    },
    {
        itemID = 133716,
        name = "Soggy Drakescale",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Stormheim waters for the scale used to catch Graybelly Lobster.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133716",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124110,
        auctionable = true,
    },
    {
        itemID = 133717,
        name = "Enchanted Lure",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Suramar waters for the lure used to catch Magic-Eater Frog.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133717",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124111,
        auctionable = true,
    },
    {
        itemID = 133719,
        name = "Sleeping Murloc",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Suramar waters for this murloc. It scatters fish when released; move over the fish to collect them.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133719",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124111,
        auctionable = true,
    },
    {
        itemID = 133720,
        name = "Demonic Detritus",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Suramar waters for the detritus used to catch Tainted Runescale Koi.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133720",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124111,
        auctionable = true,
    },
    {
        itemID = 133721,
        name = "Message in a Beer Bottle",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Broken Isles ocean waters for the bottle; open it for Axefish Lure.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133721",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124112,
        auctionable = true,
    },
    {
        itemID = 133722,
        name = "Axefish Lure",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Open Message in a Beer Bottle for this bait, then fish the Broken Isles ocean for Axefish.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133722",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124112,
        auctionable = true,
    },
    {
        itemID = 133723,
        name = "Stunned, Angry Shark",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Broken Isles ocean waters for the shark; be ready for the hostile creature it releases.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133723",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124112,
        auctionable = true,
    },
    {
        itemID = 133724,
        name = "Decayed Whale Blubber",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Fish Broken Isles ocean waters for the blubber, then use it to attract Ravenous Fly.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133724",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124112,
        auctionable = true,
    },
    {
        itemID = 133795,
        name = "Ravenous Fly",
        professions = { "fishing" },
        category = "Fishing Bait",
        acquisitionType = "fishing-bait-chain",
        summary = "Tradeable Legion rare-fishing bait. Sell the bait unused; the rare achievement fish it attracts is bound.",
        tips = {
            "Use Decayed Whale Blubber and collect the attracted fly, a second-stage bait for Ancient Black Barracuda.",
            "Where marked Unique, check bags and bank before farming another. Source markers are fishing-water anchors, not guaranteed bait catches.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=133795",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124112,
        auctionable = true,
    },
    {
        itemID = 139405,
        name = "Kul'Tiras Marine Issue Boots",
        professions = { "fishing" },
        category = "Fishing Transmog",
        acquisitionType = "fishing",
        summary = "Rare tradeable footwear caught while fishing in the Broken Isles; equip only if keeping the appearance.",
        tips = {
            "Fish ordinary Broken Isles water while farming common fish. This is a chance side catch, not a targetable school.",
            "Keep the item unequipped for sale; do not assume the tooltip preview's random suffix or scaled level is guaranteed.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139405",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 139406,
        name = "Sea Dog Boots",
        professions = { "fishing" },
        category = "Fishing Transmog",
        acquisitionType = "fishing",
        summary = "Rare tradeable footwear caught while fishing in the Broken Isles; equip only if keeping the appearance.",
        tips = {
            "Fish ordinary Broken Isles water while farming common fish. This is a chance side catch, not a targetable school.",
            "Keep the item unequipped for sale; do not assume the tooltip preview's random suffix or scaled level is guaranteed.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139406",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 139407,
        name = "Diver's Chain Boots",
        professions = { "fishing" },
        category = "Fishing Transmog",
        acquisitionType = "fishing",
        summary = "Rare tradeable footwear caught while fishing in the Broken Isles; equip only if keeping the appearance.",
        tips = {
            "Fish ordinary Broken Isles water while farming common fish. This is a chance side catch, not a targetable school.",
            "Keep the item unequipped for sale; do not assume the tooltip preview's random suffix or scaled level is guaranteed.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139407",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 139408,
        name = "Deck Sandals",
        professions = { "fishing" },
        category = "Fishing Transmog",
        acquisitionType = "fishing",
        summary = "Rare tradeable footwear caught while fishing in the Broken Isles; equip only if keeping the appearance.",
        tips = {
            "Fish ordinary Broken Isles water while farming common fish. This is a chance side catch, not a targetable school.",
            "Keep the item unequipped for sale; do not assume the tooltip preview's random suffix or scaled level is guaranteed.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139408",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        cloneFrom = 124107,
        auctionable = true,
    },
    {
        itemID = 138967,
        name = "Big Fountain Goldfish",
        professions = { "fishing" },
        category = "Fish",
        acquisitionType = "fishing",
        summary = "Common edible fish from Legion Dalaran fountains, sewers and Margoss' Retreat; not a cooking-recipe ingredient.",
        tips = {
            "Fish the Legion version of Dalaran, not Northrend Dalaran.",
            "Can be sold as food; no crafted conversion or fixed market value is assigned.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=138967",
            "https://www.wowhead.com/guide/legion-fishing",
        },
        auctionable = true,
    },
    {
        itemID = 142336,
        name = "Falcosaur Egg",
        professions = { "cooking" },
        category = "Egg",
        acquisitionType = "mob-drop",
        summary = "Tradeable Falcosaur nest and nest-keeper loot used in Spiced Falcosaur Omelet.",
        tips = {
            "Kill and loot nest-keepers and nests in the four Falcosaur nesting areas; do not rely only on the young birds.",
            "The map markers identify documented nesting-area anchors. Active swarms change mob density; these are not guaranteed drop points.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=142336",
            "https://www.wowhead.com/item=142336/falcosaur-egg",
            "https://www.wowhead.com/guide/professions-in-patch-7-1",
            "https://www.wowhead.com/npc=115786/sharptalon-hatchling",
        },
        auctionable = true,
    },
    {
        itemID = 142335,
        name = "Pristine Falcosaur Feather",
        professions = { "tailoring" },
        category = "Feather",
        acquisitionType = "mob-drop",
        summary = "Tradeable Falcosaur feather used in Feathered Luffa; this former First Aid recipe is now Legion Tailoring.",
        tips = {
            "Kill and loot nest-keepers and nests in the four Falcosaur nesting areas; do not rely only on the young birds.",
            "The map markers identify documented nesting-area anchors. Active swarms change mob density; these are not guaranteed drop points.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=142335",
            "https://www.wowhead.com/item=142336/falcosaur-egg",
            "https://www.wowhead.com/guide/professions-in-patch-7-1",
            "https://www.wowhead.com/npc=115786/sharptalon-hatchling",
        },
        auctionable = true,
    },
    {
        itemID = 130903,
        name = "Ancient Suramar Scroll",
        professions = { "miscellaneous" },
        category = "Archaeology Keystone",
        acquisitionType = "archaeology",
        summary = "Tradeable Highborne archaeology keystone from active matching-culture dig sites, not a bound artifact or fragment.",
        tips = {
            "Survey active dig sites of the matching culture. Use the archaeology map to locate the current sites; no fixed keystone spawn is implied.",
            "Keep keystones unslotted to sell. Dig sites rotate; no permanent node pin or guaranteed yield is invented.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=130903",
            "https://www.wowhead.com/guide/legion-archaeology",
            "https://www.cymre.com/2016/06/23/legion-archaeology/",
        },
        auctionable = true,
    },
    {
        itemID = 130904,
        name = "Highmountain Ritual-Stone",
        professions = { "miscellaneous" },
        category = "Archaeology Keystone",
        acquisitionType = "archaeology",
        summary = "Tradeable Highmountain Tauren archaeology keystone from active matching-culture dig sites, not a bound artifact or fragment.",
        tips = {
            "Survey active dig sites of the matching culture. Use the archaeology map to locate the current sites; no fixed keystone spawn is implied.",
            "Keep keystones unslotted to sell. Dig sites rotate; no permanent node pin or guaranteed yield is invented.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=130904",
            "https://www.wowhead.com/guide/legion-archaeology",
            "https://www.cymre.com/2016/06/23/legion-archaeology/",
        },
        auctionable = true,
    },
    {
        itemID = 130905,
        name = "Mark of the Deceiver",
        professions = { "miscellaneous" },
        category = "Archaeology Keystone",
        acquisitionType = "archaeology",
        summary = "Tradeable Demonic archaeology keystone from active matching-culture dig sites, not a bound artifact or fragment.",
        tips = {
            "Survey active dig sites of the matching culture. Use the archaeology map to locate the current sites; no fixed keystone spawn is implied.",
            "Keep keystones unslotted to sell. Dig sites rotate; no permanent node pin or guaranteed yield is invented.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=130905",
            "https://www.wowhead.com/guide/legion-archaeology",
            "https://www.cymre.com/2016/06/23/legion-archaeology/",
        },
        auctionable = true,
    },
    {
        itemID = 139786,
        name = "Ancient Mana Crystal",
        professions = { "miscellaneous" },
        category = "Ancient Mana Item",
        acquisitionType = "world-object",
        summary = "Tradeable Suramar item that grants 50 Ancient Mana when consumed. The currency itself is not auctionable.",
        tips = {
            "Loot Ancient Mana Crystal objects and eligible caches in Suramar; most other mana objects grant currency directly.",
            "Keep the item unused for sale. The eastern underwater trench is a historical scouting area; respawns and phasing vary.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139786",
            "https://www.wowhead.com/guide/suramar",
            "https://www.wowhead.com/item=139786/ancient-mana-crystal",
        },
        auctionable = true,
    },
    {
        itemID = 139890,
        name = "Ancient Mana Gem",
        professions = { "miscellaneous" },
        category = "Ancient Mana Item",
        acquisitionType = "world-object",
        summary = "Tradeable Suramar item that grants 100 Ancient Mana when consumed. The currency itself is not auctionable.",
        tips = {
            "Loot Ancient Mana Crystal objects and eligible caches in Suramar; most other mana objects grant currency directly.",
            "Keep the item unused for sale. The eastern underwater trench is a historical scouting area; respawns and phasing vary.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=139890",
            "https://www.wowhead.com/guide/suramar",
            "https://www.wowhead.com/item=139786/ancient-mana-crystal",
        },
        auctionable = true,
    },
    {
        itemID = 129032,
        name = "Roseate Pigment",
        professions = { "inscription" },
        category = "Pigment",
        acquisitionType = "processing",
        summary = "Tradeable processed Legion pigment used directly in glyphs and housing decor.",
        tips = {
            "Mill Legion herbs or use the corresponding mass-milling recipe after unlocking it. This record adds no herb farming route.",
            "Pigment output is random; no fixed yield or circular herb-to-pigment recipe is assigned.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=129032",
            "https://www.wowhead.com/guide/legion-inscription",
        },
        auctionable = true,
    },
    {
        itemID = 129034,
        name = "Sallow Pigment",
        professions = { "inscription" },
        category = "Pigment",
        acquisitionType = "processing",
        summary = "Tradeable processed Legion pigment used directly in glyphs and housing decor.",
        tips = {
            "Mill Legion herbs or use the corresponding mass-milling recipe after unlocking it. This record adds no herb farming route.",
            "Pigment output is random; no fixed yield or circular herb-to-pigment recipe is assigned.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=129034",
            "https://www.wowhead.com/guide/legion-inscription",
        },
        auctionable = true,
    },
    {
        itemID = 151579,
        name = "Labradorite",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151579",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 151718,
        name = "Argulite",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151718",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 151719,
        name = "Lightsphene",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151719",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 151720,
        name = "Chemirine",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151720",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 151721,
        name = "Hesselian",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151721",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 151722,
        name = "Florid Malachite",
        professions = { "jewelcrafting" },
        category = "Gem",
        acquisitionType = "processing",
        summary = "Tradeable uncut Argus gem from Empyrium prospecting, used in Legion jewelry and housing.",
        tips = {
            "Prospect Empyrium in batches of five, or use Mass Prospect Empyrium after unlocking it.",
            "Yield is random. This is a processing record with no new ore route and no guaranteed gem-per-ore composition.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=151722",
            "https://www.wowhead.com/guide/legion-jewelcrafting",
            "https://www.wowhead.com/spell=31252/prospecting",
        },
        auctionable = true,
    },
    {
        itemID = 144329,
        name = "Hardened Felglass",
        professions = { "engineering" },
        category = "Engineering Reagent",
        acquisitionType = "processing",
        summary = "Tradeable legacy engineering material for Skullblaster goggles; obtainable through engineering recycling and Sprocket Containers.",
        tips = {
            "Modern engineering recycling, including Pilfer Through Parts, can return Hardened Felglass; output is random.",
            "Old Boon of the Builder mob-farm reports have character-level restrictions and failures. Do not treat the shoulder enchant as a reliable max-level farm.",
            "Sprocket Containers can also be purchased, but the vendor-only container and ordinary vendor parts are not new catalog products.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=144329",
            "https://www.wowhead.com/item=225202/pilfer-through-parts",
            "https://www.wowhead.com/spell=382374/rummage-through-scrap",
            "https://www.wowhead.com/item=144330/sprocket-container",
        },
        auctionable = true,
    },
    {
        itemID = 140781,
        name = "X-87 Battle Circuit",
        professions = { "engineering" },
        category = "Bound Crafting Input",
        acquisitionType = "mob-drop",
        summary = "Bound Legion Engineering support component from mechanical mobs in the latter half of Gnomeregan; cannot be sold directly on the Auction House.",
        tips = {
            "Obtain from mechanical mobs in the latter half of Gnomeregan while eligible for the Reaves module recipe.",
            "Check the item's Unique limit and profession requirements. Sell the finished module rather than the bound component.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=140781",
            "https://www.wowhead.com/item=140781/x-87-battle-circuit",
            "https://www.wowhead.com/guide/legion-engineering",
        },
        auctionable = false,
    },
    {
        itemID = 140782,
        name = "Neural Net Detangler",
        professions = { "engineering" },
        category = "Bound Crafting Input",
        acquisitionType = "mob-drop",
        summary = "Bound Legion Engineering support component from Mimiron in Ulduar; cannot be sold directly on the Auction House.",
        tips = {
            "Obtain from Mimiron in Ulduar while eligible for the Reaves module recipe.",
            "Check the item's Unique limit and profession requirements. Sell the finished module rather than the bound component.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=140782",
            "https://www.wowhead.com/item=140781/x-87-battle-circuit",
            "https://www.wowhead.com/guide/legion-engineering",
        },
        auctionable = false,
    },
    {
        itemID = 140783,
        name = "Predictive Combat Operations Databank",
        professions = { "engineering" },
        category = "Bound Crafting Input",
        acquisitionType = "mob-drop",
        summary = "Bound Legion Engineering support component from Iron Juggernaut in Siege of Orgrimmar; cannot be sold directly on the Auction House.",
        tips = {
            "Obtain from Iron Juggernaut in Siege of Orgrimmar while eligible for the Reaves module recipe.",
            "Check the item's Unique limit and profession requirements. Sell the finished module rather than the bound component.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=140783",
            "https://www.wowhead.com/item=140781/x-87-battle-circuit",
            "https://www.wowhead.com/guide/legion-engineering",
        },
        auctionable = false,
    },
    {
        itemID = 140784,
        name = "Fel Piston Stabilizer",
        professions = { "engineering" },
        category = "Bound Crafting Input",
        acquisitionType = "mob-drop",
        summary = "Bound Legion Engineering support component from Doomwalker in Outland Shadowmoon Valley; cannot be sold directly on the Auction House.",
        tips = {
            "Obtain from Doomwalker in Outland Shadowmoon Valley while eligible for the Reaves module recipe.",
            "Check the item's Unique limit and profession requirements. Sell the finished module rather than the bound component.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=140784",
            "https://www.wowhead.com/item=140781/x-87-battle-circuit",
            "https://www.wowhead.com/guide/legion-engineering",
        },
        auctionable = false,
    },
    {
        itemID = 140785,
        name = "Hardened Circuitboard Plating",
        professions = { "engineering" },
        category = "Bound Crafting Input",
        acquisitionType = "mob-drop",
        summary = "Bound Legion Engineering support component from mechanical mobs near 68.3,23.7 in Borean Tundra; cannot be sold directly on the Auction House.",
        tips = {
            "Obtain from mechanical mobs near 68.3,23.7 in Borean Tundra while eligible for the Reaves module recipe.",
            "Check the item's Unique limit and profession requirements. Sell the finished module rather than the bound component.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=140785",
            "https://www.wowhead.com/item=140781/x-87-battle-circuit",
            "https://www.wowhead.com/guide/legion-engineering",
        },
        auctionable = false,
    },
    {
        itemID = 146710,
        name = "Bolt of Shadowcloth",
        professions = { "tailoring" },
        category = "Bound Crafting Input",
        acquisitionType = "quest",
        summary = "Bound support reagent from the Legion legendary-crafting quest chain; not an Auction House product.",
        tips = {
            "Complete the matching legendary profession quest chain from Eliezer Hammerbeard in Legion Dalaran.",
            "This reagent is consumed when crafting its legendary item. Verify quest access and repeatability on the crafting character; it is not an ordinary mob drop.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=146710",
            "https://www.wowhead.com/legion-legendary-items-guide",
            "https://www.wowhead.com/item=146714/hammer-of-forgotten-heroes",
        },
        auctionable = false,
    },
    {
        itemID = 146711,
        name = "Bolt of Starweave",
        professions = { "tailoring" },
        category = "Bound Crafting Input",
        acquisitionType = "quest",
        summary = "Bound support reagent from the Legion legendary-crafting quest chain; not an Auction House product.",
        tips = {
            "Complete the matching legendary profession quest chain from Eliezer Hammerbeard in Legion Dalaran.",
            "This reagent is consumed when crafting its legendary item. Verify quest access and repeatability on the crafting character; it is not an ordinary mob drop.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=146711",
            "https://www.wowhead.com/legion-legendary-items-guide",
            "https://www.wowhead.com/item=146714/hammer-of-forgotten-heroes",
        },
        auctionable = false,
    },
    {
        itemID = 146712,
        name = "Wisp-Touched Elderhide",
        professions = { "leatherworking" },
        category = "Bound Crafting Input",
        acquisitionType = "quest",
        summary = "Bound support reagent from the Legion legendary-crafting quest chain; not an Auction House product.",
        tips = {
            "Complete the matching legendary profession quest chain from Eliezer Hammerbeard in Legion Dalaran.",
            "This reagent is consumed when crafting its legendary item. Verify quest access and repeatability on the crafting character; it is not an ordinary mob drop.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=146712",
            "https://www.wowhead.com/legion-legendary-items-guide",
            "https://www.wowhead.com/item=146714/hammer-of-forgotten-heroes",
        },
        auctionable = false,
    },
    {
        itemID = 146713,
        name = "Prime Wardenscale",
        professions = { "leatherworking" },
        category = "Bound Crafting Input",
        acquisitionType = "quest",
        summary = "Bound support reagent from the Legion legendary-crafting quest chain; not an Auction House product.",
        tips = {
            "Complete the matching legendary profession quest chain from Eliezer Hammerbeard in Legion Dalaran.",
            "This reagent is consumed when crafting its legendary item. Verify quest access and repeatability on the crafting character; it is not an ordinary mob drop.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=146713",
            "https://www.wowhead.com/legion-legendary-items-guide",
            "https://www.wowhead.com/item=146714/hammer-of-forgotten-heroes",
        },
        auctionable = false,
    },
    {
        itemID = 146714,
        name = "Hammer of Forgotten Heroes",
        professions = { "blacksmithing" },
        category = "Bound Crafting Input",
        acquisitionType = "quest",
        summary = "Bound support reagent from the Legion legendary-crafting quest chain; not an Auction House product.",
        tips = {
            "Complete the matching legendary profession quest chain from Eliezer Hammerbeard in Legion Dalaran.",
            "This reagent is consumed when crafting its legendary item. Verify quest access and repeatability on the crafting character; it is not an ordinary mob drop.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=146714",
            "https://www.wowhead.com/legion-legendary-items-guide",
            "https://www.wowhead.com/item=146714/hammer-of-forgotten-heroes",
        },
        auctionable = false,
    },
    {
        itemID = 251767,
        name = "Fel-Touched Lumber",
        professions = { "miscellaneous" },
        category = "Warband Housing Lumber",
        acquisitionType = "lumber",
        summary = "Warband-bound Legion housing lumber. Cannot be sold directly; gather it to craft saleable decor.",
        tips = {
            "Unlock lumber gathering through the housing introduction, then harvest marked trees in Broken Isles zones or Argus.",
            "Watch for axe markers on the minimap. Tree locations are dynamic; no invented fixed lumber nodes are mapped.",
        },
        sourceUrls = {
            "https://www.wowhead.com/item=251767",
            "https://www.wowhead.com/guide/player-housing/crafting-decor-items",
            "https://warcraft.wiki.gg/wiki/Fel-Touched_Lumber",
        },
        auctionable = false,
    },
}

for _, record in ipairs(DISCOVERIES) do
    local spots = record.cloneFrom and FishingSpots(record) or {}
    if record.itemID == 142335 or record.itemID == 142336 then
        -- Documented matriarch/nesting-area anchors; loot nests and nest-keepers nearby.
        local nestingAreas = {
            { 630, "Azsuna", "Bloodgazer nesting area", 0.3557, 0.0566 },
            { 634, "Stormheim", "Direbeak nesting area", 0.7823, 0.7645 },
            { 641, "Val'sharah", "Sharptalon nesting area", 0.4804, 0.0947 },
            { 650, "Highmountain", "Snowfeather nesting area", 0.3513, 0.2193 },
        }
        for index, area in ipairs(nestingAreas) do
            spots[#spots + 1] = Pin(record.itemID .. "-nest-" .. index,
                area[1], area[2], area[3], area[4], area[5], record.sourceUrls, record.tips)
        end
    elseif record.itemID == 139786 or record.itemID == 139890 then
        spots = {
            Pin(record.itemID .. "-trench-north", 680, "Suramar", "Eastern underwater trench; northern scouting anchor",
                0.79, 0.51, record.sourceUrls, record.tips, "world-object-scouting"),
            Pin(record.itemID .. "-trench-south", 680, "Suramar", "Eastern underwater trench; southern scouting anchor",
                0.80, 0.72, record.sourceUrls, record.tips, "world-object-scouting"),
        }
    elseif record.itemID == 140785 then
        spots = { Pin("hardened-circuitboard-plating", 114, "Borean Tundra", "Mechanical mobs; bound Reaves component",
            0.683, 0.237, record.sourceUrls, record.tips, "bound-support-mob") }
    end
    Register({
        itemID = record.itemID, itemName = record.name, expansion = "legion",
        professions = record.professions, category = record.category,
        isRoute = false, auctionable = record.auctionable,
        acquisitionType = record.acquisitionType,
        summary = record.summary, tips = record.tips,
        sourceUrls = record.sourceUrls, spots = spots,
    })
end

-- Bound blood/Argus materials remain explicit support for saleable finished crafts.
for _, itemID in ipairs({ 124124, 151568 }) do
    local item = Items[itemID]
    if item then
        item.auctionable = false
        item.category = "Bound Crafting Input"
    end
end

-- Keep the earlier herb/ore imports intact, including their explicitly opted-in seeds.
-- Copy shared spot tables before suppressing lines on non-route material records.
for _, item in pairs(Items) do
    if item.expansion == "legion" and item.category ~= "Herb" and item.category ~= "Ore" and item.isRoute ~= true then
        item.isRoute = false
        item.spots = Copy(item.spots or {})
        for _, spot in ipairs(item.spots) do spot.isRoute = false end
    end
end
