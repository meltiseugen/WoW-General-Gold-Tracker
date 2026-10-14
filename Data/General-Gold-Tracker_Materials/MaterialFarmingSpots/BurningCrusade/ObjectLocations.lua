local _, NS = ...

NS.BurningCrusadeObjectPins = NS.BurningCrusadeObjectPins or {}

function NS.AddBurningCrusadeObjectPins(objectID, objectName, maps)
    NS.BurningCrusadeObjectPins[objectID] = { name = objectName, maps = maps }
end

function NS.GetBurningCrusadeObjectCoords(objectID, uiMapID)
    local object = NS.BurningCrusadeObjectPins[objectID]
    local coords = {}
    for _, coord in ipairs(object and object.maps and object.maps[uiMapID] or {}) do
        coords[#coords + 1] = { x = coord.x, y = coord.y, label = coord.label }
    end
    return coords
end
