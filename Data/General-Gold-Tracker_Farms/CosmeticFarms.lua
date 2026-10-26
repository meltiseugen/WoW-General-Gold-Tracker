local _, NS = ...

-- Self-contained acquisition data imported from the owned collection catalog.
-- Navigation hints retain their role; no deterministic yield is inferred.
local data, catalog = NS.CosmeticDropsData, NS.FarmCatalog
catalog.farms, catalog.byID = catalog.farms or {}, catalog.byID or {}
catalog.indexes, catalog.sourceCounts = catalog.indexes or {}, catalog.sourceCounts or {}
local function Copy(values)
    local copy = {}
    for _, value in ipairs(values or {}) do copy[#copy + 1] = value end
    return copy
end
local function Index(name, key, position)
    catalog.indexes[name] = catalog.indexes[name] or {}
    catalog.indexes[name][key] = catalog.indexes[name][key] or {}
    table.insert(catalog.indexes[name][key], position)
end
local farms, addedItems = {}, 0
for _, row in ipairs(data.rows) do
    local guide = data.guides[row.guideID]
    local mapOptions, mapIDs, mapNames, seenMaps, sources = {}, {}, {}, {}, {}
    for index, option in ipairs(guide.mapOptions) do
        local copy = {}
        for key, value in pairs(option) do copy[key] = value end
        copy.id = row.farmID .. ":location:" .. index
        mapOptions[#mapOptions + 1] = copy
        if not seenMaps[option.mapID] then
            seenMaps[option.mapID] = true
            mapIDs[#mapIDs + 1], mapNames[#mapNames + 1] = option.mapID, option.mapLabel
        end
    end
    for _, url in ipairs(row.sourceUrls) do
        sources[#sources + 1] = {siteName="Cosmetic acquisition source", url=url}
    end
    local details = Copy(guide.details)
    details[#details + 1] = row.expansionLabel .. " - Patch " .. row.patch
    details[#details + 1] = "Cosmetic; " .. row.binding .. ". Sell the unused item."
    if type(row.cost) == "string" then details[#details + 1] = row.cost end
    if type(row.requirements) == "string" then details[#details + 1] = row.requirements end
    local farm = {
        id=row.farmID, name=row.itemName, primaryItemID=row.itemID,
        sourceRecordID=row.recordID, sourceType="curated", sourceDataset="GGTCosmeticFarmData",
        sourceCategory="cosmetics", sourcePath="Drops > Cosmetics", activity="cosmetic",
        contentID=row.contentID, expansion=row.expansion, expansionLabel=row.expansionLabel,
        patch=row.patch, patches=row.patches, tooltipType="Cosmetic",
        auctionable=true, saleMethod="unused-item", researchedAt=data.researchedAt,
        summary=row.summary, sourceUrls=sources, targets={},
        mapIDs=mapIDs, mapNames=mapNames, routeCount=#mapOptions,
        guide={label=guide.label, requirement=guide.requirement, action=guide.action, tips=Copy(guide.tips)},
        details=details, mapOptions=mapOptions,
    }
    farms[#farms + 1] = farm
    if not catalog.byID[farm.id] then
        if not (catalog.indexes.byItemID and catalog.indexes.byItemID[row.itemID]) then
            addedItems = addedItems + 1
        end
        local position = #catalog.farms + 1
        catalog.farms[position], catalog.byID[farm.id] = farm, position
        Index("byItemID",row.itemID,position)
        Index("byRecordID",row.recordID,position)
        Index("byActivity","cosmetic",position)
        Index("byExpansion",row.expansion,position)
        Index("bySourceCategory","cosmetics",position)
        Index("bySourceType","curated",position)
        for _, mapID in ipairs(mapIDs) do Index("byMapID",mapID,position) end
    end
end
catalog.farmCount = #catalog.farms
catalog.uniqueItemCount = (catalog.uniqueItemCount or 0) + addedItems
catalog.sourceCounts.curatedCosmetics = #farms
NS.CosmeticFarmData = {rows=data.rows, farms=farms, researchedAt=data.researchedAt}
