local _, NS = ...

-- Fill only missing non-Composed Dragonflight maps, including Raid Items.
-- Evidence and limits: docs/research/dragonflight-missing-map-audit-2026-10-23.md.
if NS.DragonflightMissingMaterialMapAudit then return end
local items = NS.MaterialFarmingSpots.items
local audit = { researchedAt = "2026-10-23", items = {}, missingItems = {}, repairedItems = {} }
NS.DragonflightMissingMaterialMapAudit = audit

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function Merge(first, second)
    local result, seen = {}, {}
    for _, list in ipairs({first or {}, second or {}}) do
        for _, value in ipairs(list) do
            if not seen[value] then result[#result + 1], seen[value] = value, true end
        end
    end
    return result
end
local maps = {
    [1978]="Dragon Isles", [2022]="The Waking Shores", [2023]="Ohn'ahran Plains",
    [2024]="The Azure Span", [2025]="Thaldraszus", [2133]="Zaralek Cavern", [2200]="Emerald Dream",
}
local mapIDs = {}
for id, name in pairs(maps) do mapIDs[name] = id end
mapIDs["Waking Shores"], mapIDs["The Waking Shore"] = 2022, 2022
mapIDs["Ohnahran Plains"], mapIDs["Azure Span"] = 2023, 2024

local function Prepare(id, sources, tips, repairLegacy)
    local item = assert(items[id], "Missing Dragonflight material " .. id)
    assert(item.expansion == "dragonflight", "Wrong expansion in Dragonflight map scope")
    assert(not item.components or #item.components == 0, "Composed item in Dragonflight map scope")
    if repairLegacy then
        assert(#item.spots == 1 and item.spots[1].id == "dragonflight-prospecting-ore-input-route"
            and not item.spots[1].mapID and #item.spots[1].coords == 12, "Unexpected legacy prospecting map")
    else
        assert(not item.spots or #item.spots == 0, "Dragonflight map would replace existing locations")
    end
    item = Copy(item)
    items[id] = item
    item.spots = {}
    item.researchedAt = audit.researchedAt
    item.sourceUrls = Merge(item.sourceUrls, Merge({"https://www.wowhead.com/item=" .. id}, sources))
    item.tips = Merge(item.tips, tips)
    audit.items[id] = true
    if repairLegacy then audit.repairedItems[id] = true else audit.missingItems[id] = true end
    return item
end

-- Retain complete input geometry and provenance. The markers locate gathering
-- inputs or modified-node search paths, not guaranteed output spawns.
local function AddInputMaps(item, inputs, routeType, action, difficulty)
    item.mapInputItemIDs = Copy(inputs)
    for _, inputID in ipairs(inputs) do
        local input = assert(items[inputID])
        for _, source in ipairs(input.spots or {}) do
            local mapID = tonumber(source.mapID) or mapIDs[source.mapName]
            assert(mapID, "Unresolved Dragonflight input map: " .. tostring(source.mapName))
            local spot = Copy(source)
            spot.id = "dragonflight-input-" .. item.itemID .. "-" .. inputID .. "-" .. source.id
            spot.mapID, spot.mapName = mapID, maps[mapID] or source.mapName
            spot.location = input.itemName .. " source - " .. (source.location or source.mapName)
            spot.routeType = routeType
            spot.inputItemID, spot.inputRouteID = inputID, source.id
            spot.farmAction = action(input.itemName)
            spot.sourceUrls = Merge(source.sourceUrls, item.sourceUrls)
            spot.tips = Merge(item.tips, source.tips)
            spot.density = "Gathering inputs; no measured yield of the selected material"
            spot.dropDifficulty = difficulty
            spot.inGameTested = false
            item.spots[#item.spots + 1] = spot
        end
    end
end

local prospectingSources = {"https://www.wowhead.com/spell=374627/dragon-isles-prospecting"}
local oreInputs = {190394,188658} -- Serevite and Draconium; all quality ranks share these node routes.

-- These old maps already exposed a Map flag but could not open: their single
-- array joined seven Waking Shores points to five Ohn'ahran points without any
-- map ID. Their source module explicitly labels both portions. Preserve every
-- point and its order, but keep each zone in a separate, non-route option.
for _, id in ipairs({192837,192840,192843,192846,192849,192852,192858,192861,192865,192868,192869,192872,192880,194545}) do
    local original = Copy(items[id].spots[1])
    local item = Prepare(id, prospectingSources, {
        "Mine Dragon Isles ore and use Jewelcrafting Prospecting. The map shows ore input locations, not a ground spawn of the selected processing output.",
        "Prospecting consumes five ores; results and quality depend on the input and profession setup. No particular output or fixed yield is guaranteed.",
    }, true)
    item.mapInputItemIDs = Copy(oreInputs)
    for _, part in ipairs({{mapID=2022,first=1,last=7},{mapID=2023,first=8,last=12}}) do
        local spot = Copy(original)
        spot.id = "dragonflight-prospecting-repaired-" .. id .. "-" .. part.mapID
        spot.inputRouteID = original.id
        spot.mapID, spot.mapName = part.mapID, maps[part.mapID]
        spot.location = maps[part.mapID] .. " - preserved prospecting ore input points"
        spot.coords = {}
        for index=part.first,part.last do spot.coords[#spot.coords + 1] = Copy(original.coords[index]) end
        spot.isRoute, spot.inGameTested = false, false
        spot.farmAction = "Mine Dragon Isles ore in the marked source areas, then prospect five matching ores for a chance at " .. item.itemName .. "."
        spot.sourceUrls = Merge(original.sourceUrls, item.sourceUrls)
        spot.tips = Merge(item.tips, original.tips)
        spot.density = "Ore input search areas; no measured yield of the selected output"
        spot.dropDifficulty = "Random prospecting output; source coordinates are split by zone and do not guarantee a particular gem or byproduct."
        item.spots[#item.spots + 1] = spot
    end
end

for _, id in ipairs({
    192838,192839,192841,192842,192844,192845,192847,192848,192850,192851,
    192853,192855,192856,192857,192859,192860,192862,192863,192866,192867,192870,192871,
}) do
    local item = Prepare(id, prospectingSources, {
        "Mine Serevite or Draconium, then use Dragon Isles Prospecting on five matching ores for a chance at the selected uncut gem.",
        "Input quality, Jewelcrafting skill and specialization affect gem quality and results. This map does not guarantee a particular gem or quality rank.",
        "The paths retain the existing mining routes and their sources. Gems are processing outputs, not ground spawns on those paths.",
    })
    AddInputMaps(item, oreInputs, "prospecting-input-route", function(name)
        return "Mine " .. name .. ", then prospect five matching Dragon Isles ores with Jewelcrafting for a chance at " .. item.itemName .. "."
    end, "Random prospecting output and quality; no guaranteed target gem or fixed yield.")
end

-- Each pigment has a specific herb family. Do not send every pigment to every herb.
local pigmentInputs = {
    {ids={198412,198413,198414}, herb=191467}, -- Serene / Bubble Poppy
    {ids={198415,198416,198417}, herb=191470}, -- Flourishing / Writhebark
    {ids={198418,198419,198420}, herb=191464}, -- Blazing / Saxifrage
    {ids={198421,198422,198423}, herb=191460}, -- Shimmering / Hochenblume
}
for _, family in ipairs(pigmentInputs) do
    for _, id in ipairs(family.ids) do
        local item = Prepare(id, {
            "https://www.method.gg/guides/what-dragonflight-herbs-do-you-need-to-mill-to-get-each-pigment",
        }, {
            "Gather the named herb family, then mill it with Dragon Isles Inscription for the matching pigment. The route marks herbs, not pigment drops.",
            "Choose the input quality and profession setup for the desired pigment rank; processing results and quantities are not guaranteed by the map.",
        })
        AddInputMaps(item, {family.herb}, "milling-input-route", function(name)
            return "Gather " .. name .. ", then use Dragon Isles Milling for " .. item.itemName .. "."
        end, "Milling consumes herbs; output quantity and quality depend on input and profession setup.")
    end
end

for _, id in ipairs({193368,193369,193370}) do
    local item = Prepare(id, Merge(prospectingSources, {
        "https://www.wowhead.com/spell=395696/dragon-isles-crushing",
    }), {
        "Mine Dragon Isles ore, prospect it into raw gems, then use Dragon Isles Crushing on three eligible gems to make Silken Gemdust.",
        "Gemdust is a gem-crushing output. The ore routes are the first step of this processing chain, not direct Gemdust drops.",
        "Compare selling the ore or raw gems with crushing them. Input quality and profession setup affect the result; no fixed Gemdust yield is assumed.",
    })
    item.summary = "Dragon Isles Jewelcrafting gem-crushing output; mine ore, prospect raw gems, then crush eligible gems into Silken Gemdust."
    AddInputMaps(item, oreInputs, "prospecting-crushing-input-route", function(name)
        return "Mine " .. name .. ", prospect five matching ores, then crush three eligible Dragon Isles gems into Silken Gemdust."
    end, "Two processing steps: ore prospecting followed by gem crushing; no fixed output quantity or quality.")
end

local elementalSources = {"https://www.wowhead.com/guide/professions/farming-rousing-and-awakened-essences"}
local nodeInputs = {190394,188658,191460,191464,191467,191470}
local order = Prepare(190322, {
    "https://www.wowhead.com/guide/professions/farming-awakened-and-rousing-order",
}, {
    "With Dragon Isles Mining or Herbalism, search the existing gathering paths for Titan-Touched nodes and gather them for Rousing Order.",
    "Titan-Touched is a node modifier, not a fixed spawn. Ordinary ore and herbs on these paths do not guarantee Order; clear nodes to allow new spawn rolls.",
    "Gathering is the intended source here. This is not an ordinary creature-drop farm, and the map does not assume extra Order from Overload.",
})
AddInputMaps(order, nodeInputs, "modified-node-search", function(name)
    return "Follow the " .. name .. " gathering path and harvest Titan-Touched nodes for Rousing Order."
end, "Requires Mining or Herbalism and the Titan-Touched modifier; normal nodes do not guarantee Order.")

local ire = Prepare(190451, Merge(elementalSources, {
    "https://www.wowhead.com/spell=389464/infurious-serevite-deposit",
    "https://diamondlobby.com/world-of-warcraft/how-to-get-rousing-ire-wow-dragonflight/",
}), {
    "Enable War Mode before gathering Infurious ore or herbs. The paths locate gathering opportunities, not permanent Infurious spawns.",
    "War Mode enables hostile player encounters. Rousing Ire can also come from eligible instanced PvP rewards and Dragon Isles War Supply Chests; those are not fixed creature farms.",
    "Fury of Battle from Infurious gathering can provide another chance through player combat. No player-kill or gathering yield is guaranteed.",
})
AddInputMaps(ire, nodeInputs, "warmode-modified-node-search", function(name)
    return "Enable War Mode, follow the " .. name .. " path, and gather Infurious nodes for Rousing Ire."
end, "War Mode and Infurious nodes required for gathering; routes have no guaranteed modified-node locations.")

local function AddArea(item, suffix, mapID, location, action, options)
    options = options or {}
    local spot = {
        id="dragonflight-missing-" .. item.itemID .. "-" .. suffix,
        mapID=mapID, mapName=maps[mapID], location=location,
        routeType=options.routeType or "source-area", isRoute=false,
        mapOnly=not options.coords, coords=options.coords or {},
        farmAction=action, source=options.source or "Published item acquisition and location research",
        sourceUrls=Copy(item.sourceUrls), tips=Copy(item.tips),
        density="No measured yield", dropDifficulty=options.difficulty or "Chance-based source; no guaranteed drop or fixed spawn.",
        confidence=options.confidence or "source-area", inGameTested=false,
    }
    item.spots[#item.spots + 1] = spot
end

local decay = Prepare(190330, Merge(elementalSources, {
    "https://www.wowhead.com/item=190330/rousing-decay",
    "https://www.wow-professions.com/farming/rousing-decay-farming",
    "https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight",
}), {
    "Kill and loot eligible decay creatures around Brackenhide and Blackenhide Outskirts; bring a group for elite packs if needed.",
    "The Oozing Decay camp and Creektooth positions are player-reported search areas. Old respawn times and hourly yields are not treated as current guarantees.",
    "Herbalists can alternatively gather Decayed herbs in western Azure Span. Account for their disease effect and your profession specialization.",
})
AddArea(decay,"brackenhide",2024,"Brackenhide and Blackenhide Outskirts - Rotting Treants and decay creatures",
    "Kill and loot eligible Rotting Treants and other decay creatures around the Brackenhide area.")
AddArea(decay,"oozing-camp",2024,"Reported Oozing Decay camp near 18,34",
    "Search the reported camp for eligible Oozing Decay and loot kills for a chance at Rousing Decay.",
    {coords={{x=0.18,y=0.34,label="Reported Oozing Decay camp; search-area marker"}},confidence="player-reported"})
AddArea(decay,"creektooth",2024,"Creektooth Den - reported Errant Rot source",
    "Search Creektooth Den for Errant Rot; this is an alternative reported creature source.",
    {coords={{x=0.14,y=0.21,label="Creektooth Den search area"}},confidence="player-reported"})
AddArea(decay,"decayed-herbs",2024,"Western Azure Span - Decayed herb search",
    "Use Herbalism on eligible Decayed herbs; handle the disease effect and check profession requirements.")

local hide = Prepare(193258, {"https://www.wowhead.com/item=193258/fire-infused-hide"}, {
    "Use Skinning on eligible fiery creatures in the Dragon Isles. The item tooltip establishes this source family but does not identify a fixed skinning location.",
    "The item acquisition page also lists fishing in the Waking Shores, Zaralek Cavern and Emerald Dream. These are side-catch alternatives without a fixed pin or guaranteed catch.",
})
hide.summary = "Saleable rare skinning material from eligible fiery creatures in the Dragon Isles; listed fishing side catches are alternative sources."
AddArea(hide,"fiery-creatures",1978,"Dragon Isles - eligible fiery creatures",
    "Kill and skin eligible fiery creatures for a chance at Fire-Infused Hide; no particular beast or fixed spawn is guaranteed.")
for _, mapID in ipairs({2022,2133,2200}) do
    AddArea(hide,"fishing-" .. mapID,mapID,maps[mapID] .. " - fishing side catch",
        "Fish in the source waters listed on the item acquisition page for a chance at Fire-Infused Hide as a side catch.")
end

local orb = Prepare(201406, {
    "https://www.wowhead.com/item=201406/glowing-titan-orb",
    "https://us.forums.blizzard.com/en/wow/t/glowing-titan-orb/1442071",
}, {
    "Kill and loot eligible titan constructs around Tyrhold, including Tyrhold Watchers, Custodial Protectors and Malfunctioning Protectors.",
    "Zaralek's Containment Enforcers, Contamination Investigators and Contamination Guards are listed alternatives. The map identifies the zone, not a single established spawn pin.",
    "These are chance drops. Group where appropriate and do not rely on historical quest-button tricks, drop percentages, or income estimates.",
})
AddArea(orb,"tyrhold",2025,"Tyrhold - eligible titan constructs",
    "Search Tyrhold for eligible titan constructs and loot kills for a chance at Glowing Titan Orb.")
AddArea(orb,"zaralek",2133,"Zaralek Cavern - listed titan containment enemies",
    "Locate eligible Containment Enforcers, Contamination Investigators or Contamination Guards in Zaralek and loot kills.")

local raidEntries = {
    {id=208212,mapID=2200,name="Amirdrassil, the Dream's Hope",x=0.2730,y=0.3104,
     source="https://blizzardwatch.com/2023/11/13/amirdrassil-raid-entrance/"},
    {id=204464,mapID=2133,name="Aberrus, the Shadowed Crucible",x=0.4846,y=0.1035,
     source="https://dotesports.com/wow/news/how-to-get-to-aberrus-the-shadowed-crucible-in-wow-dragonflight"},
}
for _, entry in ipairs(raidEntries) do
    local item = Prepare(entry.id, {entry.source,
        "https://gaminghero.io/wow-gold-making-in-raids/",
    }, {
        "Enter the named raid and defeat eligible bosses for a chance at the reagent. The marker identifies the outdoor entrance, not an individual boss or guaranteed drop.",
        "Respect raid loot eligibility and the selected difficulty's lockout. Repeating a locked boss does not create unlimited reward attempts; no fixed yield is assumed.",
    })
    AddArea(item,"raid-entrance",entry.mapID,entry.name .. " entrance",
        "Enter " .. entry.name .. " and loot eligible raid bosses for a chance at " .. item.itemName .. ".", {
            routeType="raid-entrance",confidence="published-entrance",
            coords={{x=entry.x,y=entry.y,label=entry.name .. " outdoor entrance"}},
            difficulty="Raid reward eligibility and lockouts apply; reagent drops are not guaranteed.",
        })
    if entry.id == 204464 then
        item.tips = Merge(item.tips, {"Shadowflame Essence is also reported from Amirdrassil and certain outdoor bosses. The raid entrance shown here is the original Aberrus source, not an exclusive-source claim."})
        local alternate = Copy(raidEntries[1])
        item.sourceUrls = Merge(item.sourceUrls, {alternate.source})
        AddArea(item,"amirdrassil",2200,"Amirdrassil, the Dream's Hope entrance - alternative source",
            "Enter Amirdrassil and loot eligible bosses for a chance at Shadowflame Essence.", {
                routeType="raid-entrance",confidence="published-entrance",
                coords={{x=alternate.x,y=alternate.y,label="Amirdrassil outdoor entrance; alternative raid source"}},
                difficulty="Raid reward eligibility and lockouts apply; no guaranteed reagent drop.",
            })
        for _, spot in ipairs(item.spots) do
            spot.tips, spot.sourceUrls = Copy(item.tips), Copy(item.sourceUrls)
        end
    end
end
