local _, NS = ...

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

NS.BurningCrusadeNpcPins = NS.BurningCrusadeNpcPins or {}

function NS.AddBurningCrusadeNpcPins(npcID, npcName, maps)
    NS.BurningCrusadeNpcPins[npcID] = { name = npcName, maps = maps }
end

function NS.GetBurningCrusadeNpcCoords(npcIDs, uiMapID)
    local coords = {}
    for _, npcID in ipairs(npcIDs or {}) do
        local npc = NS.BurningCrusadeNpcPins[npcID]
        for _, coord in ipairs(npc and npc.maps and npc.maps[uiMapID] or {}) do
            coords[#coords + 1] = {
                x = coord.x,
                y = coord.y,
                label = coord.label,
                targetName = npc.name,
                targetType = "kill",
            }
        end
    end
    return coords
end
