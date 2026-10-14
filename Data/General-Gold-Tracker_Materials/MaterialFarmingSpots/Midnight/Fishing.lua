local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function Spots(...)
    local merged = {}
    local groups = { ... }

    for _, group in ipairs(groups) do
        for _, spot in ipairs(group or {}) do
            merged[#merged + 1] = spot
        end
    end

    return merged
end

local EVERSONG = H.MIDNIGHT_FISHING_EVERSONG_SPOTS
local ZULAMAN = H.MIDNIGHT_FISHING_ZULAMAN_SPOTS
local HARANDAR = H.MIDNIGHT_FISHING_HARANDAR_SPOTS
local VOIDSTORM = H.MIDNIGHT_FISHING_VOIDSTORM_SPOTS

local function RegisterFish(itemID, itemName, spots, summary)
    Register(H.BuildMidnightItem(
        itemID,
        itemName,
        { "fishing", "cooking" },
        "Fish",
        {
            "https://www.wowhead.com/item=" .. tostring(itemID),
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
            "https://www.method.gg/guides/midnight-fishing-profession-guide",
            "https://www.wow-professions.com/guides/wow-fishing-leveling-guide",
        },
        summary,
        spots
    ))
end

RegisterFish(238371, "Arcane Wyrmfish", Spots(EVERSONG, HARANDAR), "Eversong and Harandar fish. Open water works, but Bubbling Bloom, Sunwell Swarm, and Blossoming Torrent pools improve targeting.")
RegisterFish(238366, "Lynxfish", Spots(EVERSONG, ZULAMAN), "Eversong and Zul'Aman fish used for cooking and Majestic Eversong Lures.")
RegisterFish(238367, "Root Crab", Spots(ZULAMAN, HARANDAR), "Zul'Aman and Harandar fish, with comments pointing to Zul'Aman coast movement for reliable checks.")
RegisterFish(238365, "Sin'dorei Swarmer", Spots(EVERSONG, ZULAMAN), "Eversong and Zul'Aman fish from open water and local pool types.")
RegisterFish(238377, "Blood Hunter", Spots(ZULAMAN, VOIDSTORM), "Zul'Aman and Voidstorm fish from Surface Ripple, Hunter Surge, Viscous Void, and Oceanic Vortex pools.")
RegisterFish(238369, "Bloomtail Minnow", HARANDAR, "Harandar fish from Lashing Waves and related Harandar water checks.")
RegisterFish(238370, "Shimmer Spinefish", Spots(EVERSONG, HARANDAR), "Eversong and Harandar fish from Bloom Swarm, Bubbling Bloom, Sunwell Swarm, and Blossoming Torrent pools.")
RegisterFish(238375, "Fungalskin Pike", Spots(ZULAMAN, HARANDAR), "Zul'Aman and Harandar fish used for cooking and Majestic Harandar Lures.")
RegisterFish(238382, "Gore Guppy", ZULAMAN, "Zul'Aman fish from Surface Ripple and Hunter Surge pools, also used for Majestic Zul'Aman Lures.")
RegisterFish(238372, "Restored Songfish", Spots(EVERSONG, HARANDAR), "Eversong and Harandar fish from Bloom Swarm, Bubbling Bloom, Sunwell Swarm, and Blossoming Torrent pools.")
RegisterFish(238378, "Shimmersiren", VOIDSTORM, "Voidstorm fish from Viscous Void and Oceanic Vortex pools.")
RegisterFish(238384, "Sunwell Fish", EVERSONG, "Eversong fish from Sunwell Swarm and Blossoming Torrent checks.")
RegisterFish(238374, "Tender Lumifin", Spots(EVERSONG, HARANDAR), "Eversong and Harandar fish, with Harandar and Silvermoon water comments confirming useful open-water checks.")
RegisterFish(238383, "Eversong Trout", EVERSONG, "Eversong fish from Sunwell Swarm and Bubbling Bloom pools.")
RegisterFish(238381, "Hollow Grouper", VOIDSTORM, "Voidstorm fish from Viscous Void and Oceanic Vortex pools.")
RegisterFish(238376, "Lucky Loa", ZULAMAN, "Zul'Aman fish from Obscured School and Surface Ripple pools.")
RegisterFish(238380, "Null Voidfish", VOIDSTORM, "Voidstorm fish from Viscous Void and Oceanic Vortex pools, important for lure and cooking recipes.")
RegisterFish(238373, "Ominous Octopus", VOIDSTORM, "Voidstorm fish from Viscous Void and Oceanic Vortex pools, used for cooking and Majestic Voidstorm Lures.")
RegisterFish(238368, "Twisted Tetra", Spots(HARANDAR, ZULAMAN), "Harandar and Zul'Aman fish from Obscured School and Lashing Waves pools.")
RegisterFish(238379, "Warping Wise", VOIDSTORM, "Voidstorm fish from Viscous Void and Oceanic Vortex pools.")
