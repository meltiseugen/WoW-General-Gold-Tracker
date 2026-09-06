local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local PROSPECTING_SOURCE_URLS = {
    "https://www.method.gg/guides/midnight-jewelcrafting-profession-guide",
    "https://www.wowhead.com/guide/midnight/professions/jewelcrafting-overview-trainer-locations-recipes-tools",
}

local function RegisterProspecting(itemID, itemName, summary)
    Register(H.BuildMidnightItem(
        itemID,
        itemName,
        { "jewelcrafting", "mining" },
        "Prospecting",
        {
            "https://www.wowhead.com/item=" .. tostring(itemID),
            PROSPECTING_SOURCE_URLS[1],
            PROSPECTING_SOURCE_URLS[2],
        },
        summary,
        H.MIDNIGHT_PROSPECTING_SPOTS
    ))
end

RegisterProspecting(242553, "Sanguine Garnet", "Common Midnight prospecting gem. Method lists it from Refulgent Copper and Brilliant Silver prospecting.")
RegisterProspecting(242607, "Harandar Peridot", "Common Midnight prospecting gem. Method lists it from Refulgent Copper and Umbral Tin prospecting.")
RegisterProspecting(242554, "Amani Lapis", "Common Midnight prospecting gem. Method lists it from Refulgent Copper and Brilliant Silver prospecting.")
RegisterProspecting(242721, "Tenebrous Amethyst", "Common Midnight prospecting gem. Method lists it from Refulgent Copper and Umbral Tin prospecting.")
RegisterProspecting(242612, "Flawless Amani Lapis", "Rare Midnight prospecting gem associated with Brilliant Silver prospecting.")
RegisterProspecting(242724, "Flawless Sanguine Garnet", "Rare Midnight prospecting gem associated with Brilliant Silver prospecting.")
RegisterProspecting(242726, "Flawless Harandar Peridot", "Rare Midnight prospecting gem associated with Umbral Tin prospecting.")
RegisterProspecting(242725, "Flawless Tenebrous Amethyst", "Rare Midnight prospecting gem associated with Umbral Tin prospecting.")
RegisterProspecting(242712, "Eversong Diamond", "Rare Midnight diamond from prospecting, with specialization improving chance from Midnight ores.")
RegisterProspecting(242789, "Dusk-Shrouded Stone", "Common Midnight prospecting byproduct from ore prospecting.")
RegisterProspecting(242787, "Crystalline Glass", "Common Midnight prospecting byproduct from ore prospecting.")
