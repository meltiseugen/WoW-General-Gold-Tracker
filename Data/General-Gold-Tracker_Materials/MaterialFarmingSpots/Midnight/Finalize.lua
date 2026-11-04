local _, NS = ...

-- Run after CatalogGathering: mixed gathering exports can otherwise mark
-- specialty byproducts such as motes as Mining routes again.
for _, item in pairs(NS.MaterialFarmingSpots.items) do
    if item.expansion == "midnight" and item.isRoute == false then
        for _, spot in ipairs(item.spots or {}) do
            spot.isRoute = false
        end
    end
end
