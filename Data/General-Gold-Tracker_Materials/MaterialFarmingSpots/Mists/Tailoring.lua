local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

Register({
    itemID = 72988,
    itemName = "Windwool Cloth",
    expansion = "mists",
    professions = { "tailoring" },
    category = "Cloth",
    sourceUrls = {
        "https://www.wowhead.com/item=72988/windwool-cloth",
        "https://www.wow-professions.com/farming/windwool-cloth-farming",
    },
    summary = "Baseline MoP cloth from Pandaria humanoids. Dread Wastes Ik'thik packs are the strongest targeted open-world route.",
    spots = {
        {
            id = "mists-windwool-dread-wastes-ikthik-warrior-packs",
            source = "wow-professions Windwool guide, Wowhead Windwool guide, and Ik'thik source pages",
            sourceUrls = {
                "https://www.wow-professions.com/farming/windwool-cloth-farming",
                "https://www.wowhead.com/item=72988/windwool-cloth",
                "https://www.wowhead.com/npc=65348/ikthik-warrior",
                "https://www.wowhead.com/npc=65349/ikthik-slayer",
            },
            mapName = "Dread Wastes",
            location = "Ik'thik Warrior and Slayer packs starting at 58.13, 48.39",
            routeType = "open-world-humanoid-loop",
            density = "High",
            dropDifficulty = "Strong but demanding; the mobs are level 90 and packs are large.",
            tips = {
                "Start at 58.13, 48.39, kill the first mantid pack, then move toward Valley of the Four Winds through the remaining packs.",
                "Skip the elite scorpion and guardians unless your character can kill them quickly.",
                "The route works best when each loop takes roughly three minutes so the first packs have respawned.",
            },
            coords = {
                C(0.5813, 0.4839, "Wow-professions start pack"),
                C(0.548, 0.522, "Second Ik'thik pack"),
                C(0.508, 0.560, "Third Ik'thik pack"),
                C(0.472, 0.592, "Fourth Ik'thik pack"),
                C(0.438, 0.620, "Valley-side final pack"),
            },
            confidence = "high",
        },
        {
            id = "mists-windwool-townlong-sravess-mantid-packs",
            source = "Wowhead Windwool guide and player farming route reports",
            sourceUrls = {
                "https://www.wowhead.com/item=72988/windwool-cloth",
                "https://www.reddit.com/r/wow/comments/j5s8ni/what_are_good_places_to_farm_windwool_cloth_and/",
            },
            mapName = "Townlong Steppes",
            location = "Sra'vess and island mantid packs behind Niuzao Temple",
            routeType = "open-world-humanoid-loop",
            density = "Medium to high",
            dropDifficulty = "Good backup farm, but can be crowded because it overlaps quest areas.",
            tips = {
                "Use Sra'vess when the Dread Wastes mantid route is crowded.",
                "Favor dense mantid packs and avoid long flights between isolated mobs.",
            },
            coords = {
                C(0.236, 0.150, "Sra'vess north packs"),
                C(0.284, 0.176, "Sra'vess east packs"),
                C(0.334, 0.648, "Niuzao island approach"),
                C(0.392, 0.676, "Island mantid packs"),
            },
            confidence = "medium",
        },
    },
})
