local _, NS = ...

local function CopyArray(values)
    local copy = {}
    for _, value in ipairs(values or {}) do
        copy[#copy + 1] = value
    end
    return copy
end

local function MarkMaterialResearchCoverage()
    local farmingSpots = NS.MaterialFarmingSpots
    if type(farmingSpots) ~= "table" then
        return
    end

    local researched = 0
    for _, item in pairs(farmingSpots.items or {}) do
        item.researchStatus = item.researchStatus or "researched"
        researched = researched + 1
    end

    local missing = 0
    farmingSpots.missingItems = {}

    local materialData = NS.FarmingItems
    if type(materialData) == "table" and type(materialData.items) == "table" then
        for _, item in ipairs(materialData.items) do
            local itemID = tonumber(item and item.itemID)
            if itemID and not farmingSpots.items[itemID] then
                missing = missing + 1
                farmingSpots.missingItems[itemID] = {
                    itemID = itemID,
                    expansion = item.expansion or "unknown",
                    professions = CopyArray(item.professions),
                    category = item.tag or "Material",
                    researchStatus = "missing",
                    sourceUrls = { "https://www.wowhead.com/item=" .. tostring(itemID) },
                }
            end
        end
    end

    farmingSpots.coverage = {
        mode = "curated-only",
        researched = researched,
        missing = missing,
    }
end

MarkMaterialResearchCoverage()

