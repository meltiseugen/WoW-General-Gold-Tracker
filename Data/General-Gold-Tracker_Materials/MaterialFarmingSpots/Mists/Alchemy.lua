local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

-- Spirit of Harmony is intentionally pending under the raw-material rule:
-- it is created from Motes of Harmony and is Bind on Pickup.

Register({
    itemID = 89112,
    itemName = "Mote of Harmony",
    expansion = "mists",
    professions = { "alchemy", "blacksmithing", "engineering", "inscription", "jewelcrafting", "leatherworking", "tailoring" },
    category = "Elemental",
    sourceUrls = {
        "https://www.wowhead.com/item=89112/mote-of-harmony",
        "https://www.wowhead.com/item=74837/raw-turtle-meat",
        "https://www.wow-professions.com/farming/windwool-cloth-farming",
    },
    summary = "Bind-on-pickup Pandaria reagent fragment from dense MoP mob farms, Songbell Seeds, and normal farming side drops.",
    spots = {
        {
            id = "mists-mote-harmony-dread-wastes-horrid-march-ikthik",
            source = "Retail Wowhead Mote of Harmony comments and wow-professions Windwool guide",
            sourceUrls = {
                "https://www.wowhead.com/item=89112/mote-of-harmony",
                "https://www.wow-professions.com/farming/windwool-cloth-farming",
                "https://www.wowhead.com/npc=65348/ikthik-warrior",
                "https://www.wowhead.com/npc=65349/ikthik-slayer",
            },
            mapName = "Dread Wastes",
            location = "Horrid March Ik'thik Warrior and Slayer packs",
            routeType = "open-world-humanoid-loop",
            density = "High",
            dropDifficulty = "Broad drop with RNG; dense level-90 mantid packs make the route practical and also produce Windwool Cloth.",
            tips = {
                "Use the same five-pack Dread Wastes route as Windwool Cloth farming.",
                "Klaxxi combat buffs and Potion of Luck can add value while clearing the packs.",
                "Because Motes are bind-on-pickup, farm on the character that needs the crafted Spirit of Harmony.",
            },
            coords = {
                C(0.681, 0.490, "Horrid March start pull"),
                C(0.640, 0.496, "Scar east warrior group"),
                C(0.612, 0.515, "Scar middle group"),
                C(0.584, 0.530, "Scar west group"),
                C(0.548, 0.522, "Ik'thik cloth route overlap"),
                C(0.508, 0.560, "Ik'thik return pack"),
            },
            confidence = "high",
        },
        {
            id = "mists-mote-harmony-kunlai-howlingwind-cavern",
            source = "Retail Wowhead Mote of Harmony comments",
            sourceUrls = {
                "https://www.wowhead.com/item=89112/mote-of-harmony",
                "https://www.wowhead.com/zone=5841/kun-lai-summit",
            },
            mapName = "Kun-Lai Summit",
            location = "Howlingwind Cavern north of One Keg",
            routeType = "cave-mob-loop",
            density = "Medium to high",
            dropDifficulty = "Good when uncrowded; cave sprites also pair with cloth and ore side value.",
            tips = {
                "Enter around 59,52, trigger Suspicious Snow Piles, and circle the cave.",
                "This route is worse when quest traffic is heavy, so swap to Dread Wastes if tags are contested.",
            },
            coords = {
                C(0.590, 0.520, "Howlingwind Cavern entrance"),
                C(0.604, 0.514, "Cave first snow pile"),
                C(0.622, 0.506, "Cave inner pack"),
                C(0.614, 0.532, "Cave return pack"),
            },
            confidence = "medium",
        },
        {
            id = "mists-mote-harmony-valley-sunsong-songbell",
            source = "Retail Wowhead Mote of Harmony and Mist-Touched Leather comments",
            sourceUrls = {
                "https://www.wowhead.com/item=89112/mote-of-harmony",
                "https://www.wowhead.com/item=72120/mist-touched-leather",
            },
            mapName = "Valley of the Four Winds",
            location = "Sunsong Ranch Songbell Seed plots",
            routeType = "daily-farm-plot",
            density = "Daily limited",
            dropDifficulty = "Reliable but daily-gated and character-bound by the Tillers farm.",
            tips = {
                "Use Songbell Seeds once the Tillers farm unlock allows them.",
                "At 16 farm slots, this is a steady daily top-up rather than a grind route.",
            },
            coords = {
                C(0.528, 0.482, "Sunsong Ranch farm plots"),
                C(0.534, 0.516, "Halfhill Market seed vendor area"),
            },
            confidence = "medium",
        },
    },
})
