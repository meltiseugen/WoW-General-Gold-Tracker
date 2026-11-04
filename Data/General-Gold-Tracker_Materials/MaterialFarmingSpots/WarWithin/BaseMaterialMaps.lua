local _, NS = ...

-- Non-Composed Materials only. Evidence and limits are documented in
-- docs/research/tww-missing-map-audit-2026-10-23.md.
if NS.WarWithinMissingMaterialMapAudit then return end
local items = NS.MaterialFarmingSpots.items
local audit = {researchedAt="2026-10-23",items={},missingItems={},repairedItems={}}
NS.WarWithinMissingMaterialMapAudit = audit

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function Merge(first, second)
    local result, seen = {}, {}
    for _, list in ipairs({first or {},second or {}}) do
        for _, value in ipairs(list) do
            if not seen[value] then result[#result+1],seen[value] = value,true end
        end
    end
    return result
end
local maps = {
    [2274]="Khaz Algar",[2248]="Isle of Dorn",[2214]="The Ringing Deeps",
    [2215]="Hallowfall",[2255]="Azj-Kahet",[2339]="Dornogal",
    [2213]="City of Threads",[2216]="City of Threads - Lower City",[2371]="K'aresh",
}
local mapIDs = {}
for id,name in pairs(maps) do mapIDs[name] = id end

local function Prepare(id, sources, tips, repair)
    local item = assert(items[id],"Missing War Within material " .. id)
    assert(item.expansion == "warWithin","Wrong expansion in War Within map scope")
    assert(not item.components or #item.components == 0,"Composed material in War Within map scope")
    assert(repair or not item.spots or #item.spots == 0,"Would replace existing material maps")
    item = Copy(item)
    items[id],item.spots,item.researchedAt = item,{},audit.researchedAt
    item.sourceUrls = Merge(item.sourceUrls,Merge({"https://www.wowhead.com/item=" .. id},sources))
    item.tips = Merge(tips,item.tips)
    audit.items[id] = true
    if repair then audit.repairedItems[id] = true else audit.missingItems[id] = true end
    return item
end

local function AddPlace(item, mapID, location, action, routeType, coords, sources, tips)
    local spot = {
        id="tww-map-" .. item.itemID .. "-" .. (#item.spots+1),
        mapID=mapID,mapName=assert(maps[mapID]),location=location,
        routeType=routeType,farmAction=action,isRoute=false,inGameTested=false,
        mapOnly=not coords or #coords == 0,coords=Copy(coords or {}),
        source="Published source area or entrance; see source links and acquisition notes",
        sourceUrls=Merge(item.sourceUrls,sources),tips=Merge(tips,item.tips),
        density="Variable; no measured hourly yield",
        dropDifficulty="Source access and eligibility apply; no guaranteed drop or fixed output.",
    }
    item.spots[#item.spots+1] = spot
    return spot
end

-- Repair only known malformed arrays. Do not put points from different zones on
-- one map or treat an access marker as a fishing pool.
local function Normalize(source)
    local groups
    if source.id == "tww-fishing-anglerseeker-torrent-route" then
        assert(#source.coords == 3 and not source.mapID)
        groups = {{2214,{1,3}},{2215,{2}}}
    elseif source.id == "tww-fishing-royal-ripple-hallowfall-azj-kahet-route" then
        assert(#source.coords == 7 and not source.mapID)
        groups = {{2215,{1,2,3}},{2255,{4,5,6,7}}}
    elseif source.id == "tww-fishing-azj-kahet-rare-water-route" then
        assert(#source.coords == 4 and not source.mapID)
        groups = {{2255,{1,2,3}},{2255,{4}}}
    end
    if not groups then
        local spot = Copy(source)
        spot.mapID = tonumber(spot.mapID) or mapIDs[spot.mapName]
        assert(spot.mapID,"Unresolved War Within source map: " .. tostring(spot.mapName))
        return {spot}
    end
    local result = {}
    for index,group in ipairs(groups) do
        local spot = Copy(source)
        spot.mapID,spot.mapName,spot.coords = group[1],maps[group[1]],{}
        spot.id = source.id .. "-zone-" .. index
        spot.inputRouteID = source.id
        spot.isRoute,spot.inGameTested = false,false
        for _,i in ipairs(group[2]) do spot.coords[#spot.coords+1] = Copy(source.coords[i]) end
        if source.id == "tww-fishing-azj-kahet-rare-water-route" and index == 2 then
            spot.location = "Tak-Rethan Abyss exterior approach - access only"
            spot.routeType = "fishing-area-access"
            -- Method's old 67.72,24.29 is on an unspecified City of Threads
            -- layer. Use the published /way #2255 entrance instead of guessing
            -- the layer or reusing City coordinates on the Azj-Kahet overview.
            spot.legacyCoords = Copy(spot.coords)
            spot.coords = {{x=0.548,y=0.726,label="Tak-Rethan Abyss exterior approach (not a pool)"}}
            spot.sourceUrls = Merge(spot.sourceUrls,{"https://www.wowhead.com/achievement=40437/delver-of-the-depths"})
            spot.tips = Merge({"Access marker uses the published /way #2255 54.8 72.6 entrance. The old City of Threads coordinates used a different layer. This is not a confirmed fishing pool; use the separate water option to fish."},spot.tips)
        end
        result[#result+1] = spot
    end
    return result
end

local function AddInputs(item, inputs, routeType, action, difficulty)
    item.mapInputItemIDs = Copy(inputs)
    for _,id in ipairs(inputs) do
        local input = assert(items[id])
        for _,source in ipairs(input.spots or {}) do
            for _,spot in ipairs(Normalize(source)) do
                local accessOnly = spot.routeType == "fishing-area-access"
                spot.inputRouteID = spot.inputRouteID or source.id
                spot.id = "tww-input-" .. item.itemID .. "-" .. id .. "-" .. spot.id
                spot.inputItemID = id
                spot.location = input.itemName .. " source - " .. (spot.location or spot.mapName)
                spot.routeType,spot.farmAction = routeType,action(input.itemName)
                if accessOnly then
                    spot.mapRole = "access"
                    spot.farmAction = "Access marker only; use the separate water option for the fishing input. " .. spot.farmAction
                end
                spot.sourceUrls,spot.tips = Merge(spot.sourceUrls,item.sourceUrls),Merge(item.tips,spot.tips)
                spot.density,spot.dropDifficulty = "Input gathering; no measured target yield",difficulty
                spot.inGameTested = false
                item.spots[#item.spots+1] = spot
            end
        end
    end
    assert(#item.spots > 0,"No input maps for " .. item.itemID)
end

for _,id in ipairs({220153,220148,220151,220146,220144,220150,222533,213197}) do
    local original = items[id].spots
    local item = Prepare(id,{}, {
        "These are inherited gathering search points. Pool types and rare bonus reagents are not guaranteed at any marker.",
    },true)
    for _,source in ipairs(original) do
        -- The old shared Anglerseeker template incorrectly offered this fish
        -- outside Azj-Kahet. Retain its supported open-water source instead.
        if id ~= 220153 or source.id ~= "tww-fishing-anglerseeker-torrent-route" then
            for _,spot in ipairs(Normalize(source)) do
                spot.inGameTested = false
                spot.farmAction = id == 213197
                    and "Gather Khaz Algar herbs for a chance at Null Lotus as a rare bonus; there is no dedicated Lotus node."
                    or "Search the marked waters for " .. item.itemName .. "; follow the pool and bait requirements in Tips."
                if spot.routeType == "fishing-area-access" then
                    spot.farmAction = "Travel to the Tak-Rethan Abyss exterior approach, then use the separate water search option to fish."
                end
                spot.sourceUrls,spot.tips = Merge(spot.sourceUrls,item.sourceUrls),Merge(spot.tips,item.tips)
                item.spots[#item.spots+1] = spot
            end
        end
    end
    if id == 220153 then
        item.tips = Merge({"Fish Azj-Kahet open water with Whispers of the Deep from throwing Whispering Stargazer back. The buff is consumed by a successful catch; no minimum skill or catch count is guaranteed."},item.tips)
        for _,spot in ipairs(item.spots) do spot.tips = Merge(item.tips,spot.tips) end
    end
end

-- Supplied routes already worked for these raw materials, hiding the fact that
-- their older single-zone alternatives lacked map IDs. Retain every route,
-- point, order and export while making those alternatives openable too.
for _,id in ipairs({
    210796,210797,210798,210799,210800,210801,210802,210803,210804,
    210805,210806,210807,210808,210809,210810,
    210930,210931,210932,210933,210934,210935,210936,210937,210938,
}) do
    local original,needsID = items[id].spots,false
    for _,spot in ipairs(original) do if not spot.mapID then needsID = true end end
    assert(needsID,"Expected legacy single-zone gathering alternatives")
    local item = Prepare(id,{}, {
        "Existing supplied and researched gathering paths are retained. Node presence and yields vary; these are search paths, not fixed node spawns.",
    },true)
    for _,source in ipairs(original) do
        for _,spot in ipairs(Normalize(source)) do
            spot.farmAction = "Gather " .. item.itemName .. " along the supplied or researched " .. spot.mapName .. " path."
            spot.tips,spot.sourceUrls = Merge(spot.tips,item.tips),Merge(spot.sourceUrls,item.sourceUrls)
            spot.inGameTested = false
            item.spots[#item.spots+1] = spot
        end
    end
end

for _,family in ipairs({
    {ids={222618,222619,222620},input=210796}, -- Nacreous / Mycobloom
    {ids={222612,222613,222614},input=210799},
    {ids={224800,224801,224802},input=210802},
    {ids={224803,224804,224805},input=210805},
}) do
    for _,id in ipairs(family.ids) do
        local item = Prepare(id,{
            "https://www.method.gg/guides/the-war-within-herb-milling-and-pigment-guide",
            "https://www.method.gg/guides/the-war-within-inscription-profession-leveling-guide",
        },{"Milling consumes ten matching Khaz Algar herbs. Input quality and Inscription setup affect pigment rank; the map locates herbs, not pigment drops."})
        AddInputs(item,{family.input},"milling-input-route",function(name)
            return "Gather " .. name .. ", then use Khaz Algar Milling on ten matching herbs for " .. item.itemName .. "."
        end,"Herb gathering followed by Milling; output quantity and quality vary.")
    end
end

for _,id in ipairs({213219,213220,213221}) do
    local item = Prepare(id,{"https://www.wowhead.com/spell=434020/algari-crushing"},{
        "Algari Crushing consumes three eligible Khaz Algar gems AND ten Bismuth. Gather ore, prospect for gems, then crush; these are input routes, not Gemstone drops.",
    })
    AddInputs(item,{210930},"prospecting-crushing-input-route",function(name)
        return "Mine " .. name .. ", prospect ore for raw gems, then use Algari Crushing with three gems and ten Bismuth for Crushed Gemstones."
    end,"Prospecting and Crushing are separate steps; neither a particular gem nor an output rank is guaranteed.")
end

for _,family in ipairs({
    {ids={222795,222796,222797},input=224828},
    {ids={222789,222790,222791},input=224824},
    {ids={222792,222793,222794},input=224826},
}) do
    for _,id in ipairs(family.ids) do
        local item = Prepare(id,{
            "https://www.wowhead.com/spell=446926/unraveling",
            "https://www.method.gg/guides/the-war-within-tailoring-profession-leveling-guide",
        },{"Unravel five matching Khaz Algar cloth with Tailoring. Dawnweave and Duskweave gathering require the corresponding From Dawn Until Dusk specialization; output rank and quantity depend on setup."})
        AddInputs(item,{family.input},"unraveling-input-route",function(name)
            return "Collect " .. name .. " from eligible humanoids, then Unravel five matching cloth for " .. item.itemName .. "."
        end,"Cloth eligibility and specialization apply; markers locate cloth inputs, not thread drops.")
    end
end

for _,family in ipairs({
    {id=213611,inputs={210796,210799,210802},modifier="Altered"},
    {id=213612,inputs={210796,210799,210802,210805,210808},modifier="Sporefused"},
}) do
    local item = Prepare(family.id,{"https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview"},{
        "Search herb routes for the named node modifier. Ordinary nodes do not guarantee this reagent, and modified nodes do not have permanent spawns.",
    })
    AddInputs(item,family.inputs,"modified-node-search",function(name)
        return "Follow the " .. name .. " gathering path and harvest " .. family.modifier .. " herbs for a chance at " .. item.itemName .. "."
    end,"Requires Herbalism and the appropriate node modifier; no guaranteed secondary reagent.")
end

local blasphemite = Prepare(212514,{
    "https://www.wowhead.com/item=212514/blasphemite",
    "https://www.wowhead.com/guide/the-war-within/professions/alchemy-overview",
},{"Use Alchemy Thaumaturgy on eligible materials and the Gleaming Transmutagen processing path. Specialization matters; no fixed batch return is assumed. This is not a prospecting gem."})
AddInputs(blasphemite,{210796},"thaumaturgy-input-route",function(name)
    return "Gather " .. name .. " as Thaumaturgy feed; use Khaz Algar Alchemy and the Gleaming Transmutagen path for Blasphemite."
end,"Alchemy processing and specialization, not a direct herb-node gem drop.")

-- Species/source areas are intentionally unpinned when no supported exact farm
-- coordinate is available. They remain usable map-only navigation options.
for _,id in ipairs({223512,225566,225569}) do
    local item = Prepare(id,{"https://www.wowhead.com/npc=221523/dazzling-peafowl"},{
        "Dazzling Peafowl in Isle of Dorn have recorded drops of Basically Beef, Warped Wing and Clipped Bird Wing. Search their outdoor habitat; no exact spawn or drop rate is asserted.",
    })
    AddPlace(item,2248,"Dazzling Peafowl source area","Hunt and loot Dazzling Peafowl in Isle of Dorn for a chance at " .. item.itemName .. ".","creature-source-area")
end
local worm = Prepare(225565,{
    "https://warcraft.wiki.gg/wiki/Massive_Worm_Flank",
    "https://www.wowhead.com/npc=218393/disturbed-earthgorger",
},{"Khaz Algar worm creatures can drop this meat. Disturbed Earthgorger is a documented Ringing Deeps source, but is a rare elite rather than a continuous farming pull. No exact spawn pin or rapid respawn is assumed."})
AddPlace(worm,2214,"Worm creatures / Disturbed Earthgorger rare source","Hunt eligible worm creatures; the rare elite Disturbed Earthgorger is a recorded Ringing Deeps source of Massive Worm Flank.","creature-source-area")
local brisket = Prepare(225567,{"https://www.wowhead.com/item=225567/bug-brisket"},{
    "Azj-Kahet drop records include Harvest Hauler and Isolated Crawler. Search for these creatures; the map does not identify a measured mass-pull route.",
})
AddPlace(brisket,2255,"Harvest Hauler and Isolated Crawler source areas","Hunt and loot Harvest Haulers or Isolated Crawlers in Azj-Kahet for Bug Brisket.","creature-source-area")

local cookingSources = {"https://www.method.gg/guides/best-meat-and-fish-for-producing-ingredients-in-the-war-within"}
local scrap = Prepare(225568,Merge(cookingSources,{"https://warcraft.wiki.gg/wiki/Slum_Shark_Scrap"}),{
    "Slum Shark Scrap is a secondary Cooking output from filleting Kaheti Slum Sharks, not an ordinary shark-creature drop. Fish the input, then process five matching fish using Fresh Fillet.",
})
scrap.summary = "Cooking processing byproduct from Kaheti Slum Sharks; use the fishing input maps, then fillet the catch."
AddInputs(scrap,{220147},"fishing-processing-input-route",function()
    return "Fish Kaheti Slum Sharks, then process five with Cooking Fresh Fillet for a chance at Slum Shark Scrap."
end,"Fishing followed by Cooking salvage; Scrap is a secondary output, not a guaranteed catch.")

for _,family in ipairs({
    {id=222737,inputs={210796},spell=445117,action="Gather Mycobloom, then process five matching herbs with Cooking into Chopped Mycobloom."},
    {id=222741,inputs={220138,220147},spell=445116,action="Fish the named input, then use Cooking Fresh Fillet on five matching fish. Cursed Ghoulfish yields Prepared Ghoulfish instead."},
    {id=222738,inputs={223512,225565,225567,225568},spell=445118,action="Obtain the named meat input, then use Cooking to portion five matching meats into Portioned Steak."},
    {id=222739,inputs={223512,225565,225567,225568},spell=445119,action="Obtain the named meat input, then use Cooking to turn five matching meats into Spiced Meat Stock."},
    {id=225883,inputs={220152},spell=445116,action="Fish Cursed Ghoulfish, then process five with Cooking Fresh Fillet to obtain Prepared Ghoulfish instead of normal fillets."},
}) do
    local item = Prepare(family.id,Merge(cookingSources,{"https://www.wowhead.com/spell=" .. family.spell}),{
        family.action,"These maps locate the raw input. Processing destroys it, and Cooking skill affects the result; no fixed batch yield is assumed.",
    })
    AddInputs(item,family.inputs,"cooking-processing-input-route",function() return family.action end,"Gather or fish the input, then process it with Cooking; quantities vary.")
end

local eggSources = {
    "https://www.wowhead.com/item=223975/suspiciously-heavy-egg",
    "https://www.wowhead.com/guide/the-war-within/professions/cooking-overview",
}
for _,id in ipairs({225876,223977,223967}) do
    local tips = {
        "Learn Fine Egg Powder from Polo in City of Threads, obtain eligible eggs from Izkrk'tkrzn, then salvage eggs with Cooking. The map markers identify access to recipe/inputs, not drops of the finished material.",
        "Suspiciously Heavy Egg can produce Coagulated Yolk as a secondary output; Yesterday's Eggs are not a supported Yolk input. No fixed return is assumed.",
    }
    if id == 223967 then
        tips = {"Learn Protein Slurp from Eight-Shaker Sallow in City of Threads (Khaz Algar Cooking 35), then cook five Fine Egg Powder. The map shows the egg-input chain; Sallow is not pinned.",tips[1]}
    end
    local item = Prepare(id,eggSources,tips)
    if id == 223967 then
        item.sourceUrls = Merge(item.sourceUrls,{"https://www.wowhead.com/spell=447871/protein-slurp","https://warcraft.wiki.gg/wiki/Recipe:_Protein_Slurp"})
        item.summary = "Khaz Algar cooked drink made from five Fine Egg Powder after learning the recipe from Eight-Shaker Sallow."
        -- The old generic Fresh Fillet/meat-salvage notes are not evidence for this recipe.
        item.tips = Copy(tips)
    end
    local action = id == 223967 and "Obtain eggs and make Fine Egg Powder, then cook five powder into Protein Slurp after learning Sallow's recipe."
        or "Obtain Suspiciously Heavy Eggs from Izkrk'tkrzn, then salvage using the Fine Egg Powder recipe for powder and a chance at Coagulated Yolk."
    AddPlace(item,2216,"Izkrk'tkrzn - egg inputs",action,"cooking-input-access",{{x=0.600,y=0.316,label="Izkrk'tkrzn, egg inputs"}})
    AddPlace(item,2213,"Polo - Fine Egg Powder recipe",action,"cooking-recipe-access",{{x=0.482,y=0.248,label="Polo, Fine Egg Powder recipe"}})
end

local engineeringSources = {"https://www.wowhead.com/spell=447311/pilfer-through-parts","https://www.wowhead.com/spell=447310/scour-through-scrap"}
for _,id in ipairs({227769,225241,225242}) do
    local item = Prepare(id,engineeringSources,{
        "Craft eligible engineering parts, then Pilfer Through Parts in batches of five. Bolts can provide Bountiful Bolts and Rusted Scrap, but should not be used to target the rarer Pummeler parts.",
        "For refurbished tinkers, use Scour Through Scrap on the Rusted Scrap obtained from pilfering. Results are random; this map shows the ore feed for parts, not direct tinker drops.",
    })
    local action = id == 227769
        and "Mine Bismuth, craft Handful of Bismuth Bolts, then Pilfer Through Parts on five eligible parts for a chance at Bountiful Bolts."
        or "Mine Bismuth, craft eligible engineering parts, Pilfer Through Parts for Rusted Scrap, then Scour Through Scrap for a chance at " .. item.itemName .. "."
    AddInputs(item,{210930},"engineering-processing-input-route",function() return action end,"Requires Engineering processing; no fixed output probability or batch yield.")
end
for _,id in ipairs({227770,227771,227772,227773,227774}) do
    local item = Prepare(id,Merge(engineeringSources,{"https://www.wowhead.com/npc=223163/paxton-bombshell"}),{
        "Unlock Parts in Engineering's Inventing tree and Pilfer Through Parts on eligible components. Bolt-only inputs are not a supported route for these rare mount parts; results and Pummel Permit chances are highly variable.",
        "Processing can be done wherever permitted. Dornogal is profession context only. Paxton Bombshell at Opportunity Point offers a purchase alternative; the marker uses a player-reported correction after the 11.1 map update.",
    })
    AddPlace(item,2339,"Khaz Algar Engineering processing context","Use Engineering Pilfer Through Parts on five eligible non-bolt parts with the Parts specialization for a chance at " .. item.itemName .. ".","profession-context")
    local spot = AddPlace(item,2214,"Opportunity Point - Paxton Bombshell purchase alternative","Check Paxton Bombshell's stock as a purchase alternative to pilfering for " .. item.itemName .. ".","vendor-alternative",{{x=0.5976,y=0.7843,label="Paxton Bombshell (reported post-11.1 position)"}})
    spot.confidence = "player-reported"
end

local bloodstone = Prepare(215236,{
    "https://worldofwarcraft.blizzard.com/en-us/news/24134803/hotfixes-august-29-2024",
    "https://astro.k.icy-veins.com/wow/the-war-within-pvp-season-1-guide",
},{"Blizzard's 2024 hotfix notes added Vicious Bloodstone to eligible PvP victory boxes and describe War Mode and Honor sources. PvP rewards and vendor stock depend on the active rules; queueing does not require standing at this map marker."})
AddPlace(bloodstone,2339,"Contender's Gate - PvP quartermaster access","Earn eligible PvP rewards or check the Dornogal Honor quartermasters for Vicious Bloodstone.","pvp-hub-access",{{x=0.555,y=0.769,label="Contender's Gate quartermaster area"}})
local heraldry = Prepare(210221,{
    "https://warcraft.wiki.gg/wiki/Forged_Combatant%27s_Heraldry",
},{"Legacy Season 1 reagent: new Forged Combatant's Heraldry can no longer be earned after its season ended. Existing tradeable stock may remain on the Auction House. This map is historical source context, not a current reward farm."})
heraldry.summary = "Legacy Season 1 PvP reagent; no longer obtainable from new seasonal rewards. Existing tradeable stock may remain."
heraldry.tips = {"Forged Combatant's Heraldry is no longer obtainable from its original seasonal sources. Check existing Auction House stock; current-season heraldry is a different item."}
AddPlace(heraldry,2339,"Contender's Gate - historical Season 1 source","Historical PvP quartermaster context only: Forged Combatant's Heraldry can no longer be earned. Check existing tradeable stock instead.","legacy-season-source")

-- Pins are OUTDOOR entrances, never chest coordinates from an interior map.
-- October 2024 changes distributed reagents to Heavy Trunks across delves;
-- original launch-specific delve assignments are not guaranteed loot tables.
local delveSources = {
    "https://www.bluetracker.gg/wow/topic/eu-en/531278-the-war-within-hotfixes-16-october/",
    "https://www.wowhead.com/achievement=40437/delver-of-the-depths",
}
local delves = {
    {2248,"Earthcrawl Mines",0.387,0.736},
    {2214,"The Waterworks",0.462,0.480},
    {2215,"Nightfall Sanctum",0.351,0.462},
    {2255,"Tak-Rethan Abyss",0.548,0.726},
}
for _,id in ipairs({221754,221756,221757,221758,221763}) do
    local exchange
    if id == 221758 then
        assert(#items[id].spots == 2 and items[id].spots[1].id == "tww-reagent-nightfall-sanctum-profaned-tinderbox-route")
        exchange = Copy(items[id].spots[2])
    end
    local item = Prepare(id,delveSources,{
        "Enter a Khaz Algar delve and check eligible Heavy Trunks and rewards for specialty reagents. Historical hotfix notes broadened their distribution; a particular reagent or drop probability is not guaranteed by this entrance choice.",
        "Markers are exterior access points. The old Nightfall Sanctum 39.12,74.33 Sturdy Chest is an interior, one-time exploration treasure and is not a repeatable outdoor farming pin.",
        "Delver's Pouch of Reagents was removed in 12.0.1 and is not used as a current farming source here. Delve access and reward eligibility still apply.",
    },exchange ~= nil)
    item.summary = "Delve specialty reagent: navigate to an outdoor entrance, then check eligible Heavy Trunks and rewards; no fixed per-delve yield."
    -- Replace obsolete reset/chest advice instead of retaining it beside corrected instructions.
    item.tips = {
        "Enter a Khaz Algar delve and check eligible Heavy Trunks and rewards. Entrance choices do not guarantee a particular reagent or a fixed drop rate.",
        "These are exterior entrances. Nightfall Sanctum's interior Sturdy Chest is a one-time exploration treasure, not a repeatable outdoor source.",
        "Delver's Pouch of Reagents was removed in 12.0.1; it is not a current farm. Access, loot eligibility and patch changes apply.",
    }
    item.sourceUrls = Merge(item.sourceUrls,{"https://warcraft.wiki.gg/wiki/Delver%27s_Pouch_of_Reagents","https://www.cymre.com/2024/08/21/treasures-of-khaz-algar/"})
    for _,delve in ipairs(delves) do
        local spot = AddPlace(item,delve[1],delve[2] .. " - exterior entrance","Enter " .. delve[2] .. " and check eligible delve Heavy Trunks and rewards for a chance at " .. item.itemName .. ".","delve-entrance",{{x=delve[3],y=delve[4],label=delve[2] .. " exterior entrance"}})
        spot.mapRole,spot.confidence = "entrance","published-entrance"
    end
    if exchange then
        exchange.mapID,exchange.inGameTested = 2339,false
        exchange.farmAction = "Check Borgos's Profaned Tinderbox exchange; this is a purchase alternative to delve rewards."
        exchange.sourceUrls,exchange.tips = Merge(exchange.sourceUrls,item.sourceUrls),Merge(exchange.tips,item.tips)
        item.spots[#item.spots+1] = exchange
    end
end

local instrument = Prepare(249218,{
    "https://www.blizzspirit.com/warcraft/manaforge-omega-guide-de-poche-du-raid-de-the-war-within/",
},{"Enter Manaforge Omega and defeat Forgeweaver Araz for a chance at Manaforged Instrument. The marker is the outdoor raid entrance, not the boss location. Raid access, Reshii Wraps/Phase Diving requirements and loot lockouts apply; Story Mode is not a supported reagent farm."})
local entrance = AddPlace(instrument,2371,"Manaforge Omega - exterior entrance","Enter Manaforge Omega and defeat Forgeweaver Araz for a chance at Manaforged Instrument.","raid-entrance",{{x=0.418,y=0.215,label="Manaforge Omega exterior entrance"}})
entrance.mapRole,entrance.confidence = "entrance","published-entrance"
