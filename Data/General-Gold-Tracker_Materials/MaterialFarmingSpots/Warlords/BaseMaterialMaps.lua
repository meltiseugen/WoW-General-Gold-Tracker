local _, NS = ...

-- Research and item-by-item receipts: docs/research/draenor-base-map-*-2026-10-21.*.
-- Only the base Materials list is enriched; composed records and recipes are untouched.
local DATE = "2026-10-21"
if NS.DraenorBaseMaterialMapAudit then return end
local items, base = NS.MaterialFarmingSpots.items, {}
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function Merge(...)
    local result, seen = {}, {}
    for _, list in ipairs({ ... }) do
        for _, value in ipairs(list) do
            if not seen[value] then result[#result + 1], seen[value] = value, true end
        end
    end
    return result
end
local function URL(id) return "https://www.wowhead.com/item=" .. id end
local maps = {
    [525] = "Frostfire Ridge", [534] = "Tanaan Jungle", [535] = "Talador",
    [539] = "Shadowmoon Valley (Draenor)", [542] = "Spires of Arak", [543] = "Gorgrond",
    [550] = "Nagrand (Draenor)", [582] = "Lunarfall", [590] = "Frostwall", [588] = "Ashran",
}
local mapIDs = {}
local function Key(name) return tostring(name or ""):lower():gsub("[^%a]", "") end
for id, name in pairs(maps) do mapIDs[Key(name)] = id end
mapIDs.shadowmoonvalley, mapIDs.wodshadowmoonvalley = 539, 539
mapIDs.nagrand, mapIDs.wodnagrand = 550, 550
local audit = { researchedAt = DATE, scope = "Draenor base Materials; composed excluded", items = {}, rejectedSpots = {} }
for _, row in ipairs(NS.FarmingItems.items) do
    if row.expansion == "warlords" and (type(row.components) ~= "table" or #row.components == 0) then
        local id = row.itemID
        base[id] = row
        -- Other records sometimes share the very same spot table. Copy before enrichment.
        local item = Copy(items[id] or { itemID = id, itemName = row.itemName, expansion = "warlords" })
        items[id] = item
        item.researchedAt = DATE
        item.sourceUrls = Merge(item.sourceUrls or {}, { URL(id) })
        local spots = {}
        for _, spot in ipairs(item.spots or {}) do
            spot.mapID = tonumber(spot.mapID) or mapIDs[Key(spot.mapName)]
            if id == 109133 and spot.id == "warlords-rylak-egg-shadowmoon-darktide-roost" then
                audit.rejectedSpots[#audit.rejectedSpots + 1] = { itemID = id, spotID = spot.id, reason = "Giant Rylak Egg is an assault/achievement object, not a supported cooking-material loot source" }
            elseif id == 127759 and spot.id == "warlords-felblight-tanaan-fangrila-skinning-fishing-route" then
                audit.rejectedSpots[#audit.rejectedSpots + 1] = { itemID = id, spotID = spot.id, reason = "Saberon humanoid packs are not supported skinning or fishing anchors" }
            elseif maps[spot.mapID] then
                spot.mapName = maps[spot.mapID]
                spot.sourceUrls = Merge(spot.sourceUrls or {}, item.sourceUrls)
                spot.tips = Merge(spot.tips or {}, {
                    "Locations are source or scouting anchors; current spawn density and hourly yield have not been measured.",
                })
                spots[#spots + 1] = spot
            else
                audit.rejectedSpots[#audit.rejectedSpots + 1] = { itemID = id, spotID = spot.id, mapID = spot.mapID }
            end
        end
        item.spots = spots
    end
end

local FISHING = "https://www.wowhead.com/guide/professions/wod/fishing-overview"
local WORK = "https://www.wowhead.com/guide/garrisons/guide-to-garrison-work-orders"
local PRESET = "https://www.wowhead.com/guide/garrisons/buildings/preset-buildings-fishing-shack-herb-garden-menagerie"
local ARCHAEOLOGY = "https://www.wowhead.com/guide/professions/wod/archaeology-overview"
local CYMRE = "https://www.cymre.com/2014/08/21/draenor-archaeology/"
local function Add(id, mapID, location, action, tips, sources, x, y, kind)
    if not base[id] then return end
    local item = items[id]
    local spot = {
        id = "warlords-base-" .. id .. "-" .. Key(location), mapID = mapID, mapName = maps[mapID],
        location = location, dropdownLabel = maps[mapID] .. ": " .. location,
        farmAction = action, tips = Copy(tips), sourceUrls = Merge({ URL(id) }, sources or {}),
        isRoute = false, routeType = kind or "source-area-guidance", confidence = "medium",
        density = "Variable; source availability and character progression apply",
        dropDifficulty = "Follow the acquisition steps; the selected output is not guaranteed on each attempt.",
        source = "Individual Retail item research and the linked source guide; area anchors are not guaranteed spawns",
        coords = {}, mapOnly = not (x and y),
    }
    if x and y then spot.coords = { { x = x, y = y, label = location } } end
    item.spots[#item.spots + 1] = spot
    item.sourceUrls = Merge(item.sourceUrls, spot.sourceUrls)
end
local function Garrisons(id, building, action, tips, sources)
    for _, entry in ipairs({ { 582, "Alliance Lunarfall" }, { 590, "Horde Frostwall" } }) do
        Add(id, entry[1], entry[2] .. " - " .. building, action,
            Merge(tips, { "Use your own faction's garrison. Building plots and upgrades vary, so this option opens the garrison without a fabricated building pin." }),
            Merge({ WORK }, sources or {}))
    end
end
local function Inputs(id, inputIDs, action, tips, sources)
    if not base[id] then return end
    local item = items[id]
    item.mapInputItemIDs = Copy(inputIDs) -- Source guidance, not deterministic components.
    for _, inputID in ipairs(inputIDs) do
        local input = items[inputID]
        for _, original in ipairs(input and input.spots or {}) do
            if not original.mapOnly and #(original.coords or {}) > 0 then
                local spot = Copy(original)
                spot.id = "warlords-base-input-" .. id .. "-" .. inputID .. "-" .. tostring(original.id)
                spot.location = input.itemName .. " input: " .. tostring(original.location)
                spot.dropdownLabel = spot.mapName .. ": " .. spot.location
                spot.sourceItemID, spot.sourceItemName = inputID, input.itemName
                spot.farmAction = action .. (original.farmAction and (" Input steps: " .. original.farmAction) or "")
                spot.isRoute, spot.routeType = false, "processing-input-source"
                spot.tips = Merge(tips, original.tips or {})
                spot.sourceUrls = Merge({ URL(id), URL(inputID) }, sources or {}, original.sourceUrls or {})
                spot.dropDifficulty = "Input source: additional processing is required. Output and bonus materials can vary."
                item.spots[#item.spots + 1] = spot
            end
        end
    end
    item.sourceUrls = Merge(item.sourceUrls, sources or {})
end

-- Fish: each independently useful water anchor gets its own dropdown choice.
-- Regional species stay inland; Sea Scorpion anchors are split into their actual zones.
items[109142].spots = {}
for _, water in ipairs({
    { 550, "Zangar Shore islands - coastal water", 0.3533, 0.4569 },
    { 525, "Southwestern Frostfire coast", 0.5610, 0.7499 },
    { 542, "Eastern Spires coast", 0.7500, 0.5000 },
}) do
    Add(109142, water[1], water[2], "Fish ocean water for Sea Scorpions, then gut and clean the matching whole fish for Sea Scorpion Segments.", {
        "Use Sea Scorpion Bait in coastal seawater; inland water targets the regional freshwater species.",
        "School positions move. These are shoreline scouting anchors, not permanent pools.",
    }, { FISHING, "https://warcraft.wiki.gg/wiki/Sea_Scorpion" }, water[3], water[4], "coastal-fishing")
end
Add(109141, 525, "Western red lake", "Fish Fire Ammonite schools and open water at the western red lake.", {
    "Scout active schools around the lake; a school can despawn after it is fished out.",
    "Use Fire Ammonite Bait and fishing gear appropriate to the size you want.",
}, { URL(111666) }, 0.3631, 0.3835, "fishing-source")
Add(109141, 525, "Central Frostfire fishing water", "Fish Fire Ammonites at this reported alternative in Frostfire Ridge.", {
    "This is a reported fishing position; schools are not guaranteed to be active.",
    "Fish size depends on fishing skill; old guides use the former 700-point scale.",
}, { URL(111666) }, 0.432, 0.479, "fishing-source")
Add(109138, 543, "Southern Gorgrond water at 43.34,80.68", "Fish inland water for Jawless Skulkers; use matching bait.", {
    "Scout adjacent pools if the reported pool is exhausted.",
    "Keep whole fish when selling them; gut and clean only when targeting flesh.",
}, { URL(111676) }, 0.4334, 0.8068, "fishing-source")
Add(109143, 542, "Akeeta's Hovel lake", "Fish the lake beside Akeeta's Hovel for Abyssal Gulper Eels.", {
    "This alternative supports open-water fishing even when no school is visible.",
    "Use Abyssal Gulper Eel Bait and keep the whole fish if it is the sale target.",
}, { URL(111664) })
local fishGroups = {
    { 109137, {111589,111595,111601} },
    { 109138, {111650,111669,111676}, 110274 },
    { 109139, {111651,111668,111675}, 110289 },
    { 109140, {111652,111667,111674}, 110290 },
    { 109141, {111656,111666,111673}, 110291 },
    { 109142, {111658,111665,111672}, 110292 },
    { 109143, {111659,111664,111671}, 110293 },
    { 109144, {111662,111663,111670}, 110294 },
}
for _, group in ipairs(fishGroups) do
    local flesh = group[1]
    local split = {}
    for _, original in ipairs(items[flesh].spots) do
        if original.mapOnly or #(original.coords or {}) <= 1 then
            split[#split + 1] = original
        else
            for index, coord in ipairs(original.coords) do
                local spot = Copy(original)
                spot.id = original.id .. "-water-" .. index
                spot.location = coord.label or original.location
                spot.dropdownLabel = spot.mapName .. ": " .. spot.location
                spot.coords = { Copy(coord) }
                split[#split + 1] = spot
            end
        end
    end
    items[flesh].spots = split
    local targets = { flesh }
    for _, id in ipairs(group[2]) do targets[#targets + 1] = id end
    if group[3] then targets[#targets + 1] = group[3] end
    -- Saberfish are a widespread fallback catch; add the established waters in other zones.
    if flesh == 109137 then
        for _, other in ipairs({ 109138, 109139, 109141, 109143, 109144 }) do
            local spot = Copy(items[other].spots[1])
            spot.id = "warlords-base-saberfish-" .. other
            spot.farmAction = "Fish open Draenor water without regional bait for Crescent Saberfish; this fallback catch is not guaranteed."
            spot.sourceUrls = { URL(111595), FISHING }
            spot.tips = { "Avoid regional bait when targeting Saberfish.", "Fishing skill changes the size distribution; no fixed catch rate is assumed." }
            items[flesh].spots[#items[flesh].spots + 1] = spot
        end
    end
    local sourceSpots = Copy(items[flesh].spots)
    for _, id in ipairs(targets) do
        if base[id] then
            if id ~= flesh then
                items[id].spots = Copy(sourceSpots)
                for _, spot in ipairs(items[id].spots) do spot.id = spot.id .. "-item-" .. id end
            end
            local action = id == flesh and "Fish the matching regional species here, then gut and clean five fish of one size for the listed flesh or segments."
                or id == group[3] and "Fish these matching waters for bait drops; use the bait for this regional species. Bait is a random fishing catch."
                or "Fish these matching waters for " .. items[id].itemName .. ". Fish size depends on skill and is not guaranteed per cast."
            for _, spot in ipairs(items[id].spots) do
                spot.farmAction = action
                spot.sourceUrls = Merge({ URL(id), FISHING }, spot.sourceUrls or {})
                spot.tips = Merge({
                    "Retail fish tooltips require five whole fish of the same size to gut and clean; old 20/10/5 stack advice predates patch 6.1.",
                    "For whole-fish sales, avoid gutting and the Bladebone Hook's automatic cleaning. For flesh, compare the output of each size.",
                    "Historical 600/700/800 fishing thresholds refer to the old skill scale; use the current Draenor fishing skill and item tooltip.",
                }, spot.tips or {})
            end
            if group[3] then
                Garrisons(id, "Fishing Shack pond", id == flesh and "Use matching regional bait at your unlocked Fishing Shack pond, then clean the fish for this flesh."
                    or id == group[3] and "Fish your unlocked garrison pond for Draenor bait; this exact bait is a possible random result."
                    or "Use the matching regional bait at your unlocked Fishing Shack pond for this species; verify that your skill and Shack progression support the desired size.", {
                    "Unlock the Fishing Shack first. Regional bait changes the species available in the pond; it does not guarantee a particular size.",
                    "This is an alternative to travelling to the source zone. Felmouth Frenzy and its bait are excluded from garrison pond guidance.",
                }, { FISHING, "https://warcraft.wiki.gg/wiki/Fishing_bait" })
            end
        end
    end
end
for _, id in ipairs({127991,128229}) do
    local action = id == 127991 and "Fish active Felmouth Frenzy Schools in Tanaan for Felmouth Frenzy."
        or "Fish Tanaan waters for Felmouth Frenzy Bait; it is a random catch, not a vendor supply."
    local tips = {
        "Use Find Fish and fly around the waters near Hellfire Citadel. Schools move; a scouting anchor does not guarantee an active pool.",
        "Felmouth bait works in Tanaan, not the garrison pond. For Felblight attempts, target the schools rather than assuming baited open water is equivalent.",
    }
    Add(id,534,"Hellfire Citadel western water schools",action,tips,{FISHING,"https://www.wowhead.com/object=243325/felmouth-frenzy-school"},0.425,0.494,"fishing-source")
    Add(id,534,"Hellfire Citadel surrounding fel-water circuit",action,tips,{FISHING,"https://warcraft.wiki.gg/wiki/Felmouth_Frenzy_Bait"})
end
Add(127759,534,"Felmouth schools west of Hellfire Citadel","Fish active Felmouth Frenzy Schools for possible Felblight bonus catches.",{
    "Follow Find Fish and move between active schools; a location anchor is not a permanent spawn.",
    "Baited open water is not advertised as equivalent to the schools for Felblight. Keep the fish as a separate byproduct.",
},{"https://www.wowhead.com/object=243325/felmouth-frenzy-school",URL(128229)},0.425,0.494,"fishing-source")
Add(127759,534,"Felbound Wolves north of Vol'mar","Kill, loot and skin eligible Felbound Wolves for Felblight attempts.",{
    "Skinning is required; normal kill loot and skinning loot are separate.",
    "Scout the wolves north of Vol'mar. This reported area may be contested; no guaranteed drop rate is assumed.",
},{"https://www.wowhead.com/quest=39529/tooth-and-claw",URL(127759)},0.61,0.36,"skinning-source")
Add(127759,534,"Thornmire ravagers","Kill, loot and skin eligible ravagers in Thornmire for possible Felblight.",{
    "These are skinnable beast alternatives, unlike the discarded saberon humanoid anchors.",
    "Find eligible corpses, loot them first and skin them; Felblight is not guaranteed on every skin.",
},{"https://www.wowhead.com/quest=39529/tooth-and-claw",URL(127759)})
Add(127759,534,"Supreme Lord Kazzak","Defeat and loot Supreme Lord Kazzak when your character has an eligible loot attempt for possible Felblight.",{
    "This is a limited world-boss loot source, not a continuously repeatable gathering farm.",
    "Check your current loot eligibility before travelling; repeat kills do not promise further rewards.",
},{"https://warcraft.wiki.gg/wiki/Felblight"})

-- Raw meat alternatives from item/NPC reports. These are normal loot, not skinning output.
local meatTips = { "Kill and loot the named adults for meat; Skinning is an optional separate step for hides.", "Move between nearby packs when contested; historical drop and respawn claims are not current measured rates." }
Add(109136,525,"Northern Frostfire boars", "Kill and loot the boars around the northern stronghold.",meatTips,{URL(109136)},0.39,0.19,"mob-farm")
Add(109136,543,"Skysea Point boars", "Kill and loot boars around Skysea Point.",meatTips,{URL(109136)})
Add(109135,535,"Eastern Talador ring lake", "Kill and loot Young Riverwallows and Riverwallowers along the lake east of Auchindoun.",meatTips,{URL(109135),"https://warcraft.wiki.gg/wiki/Riverwallower"},0.63,0.55,"mob-farm")
Add(109134,550,"Oshu'gun Tenderhoof elekk area", "Kill and loot eligible Tenderhoof elekks around Oshu'gun.",meatTips,{URL(109134),"https://www.wowhead.com/npc=78459/tenderhoof-meadowstomper"})
Add(109132,550,"Spirit Woods adult talbuks", "Kill adult talbuks or stallions around the Spirit Woods; skip colts for this meat.",meatTips,{URL(109132)})
Add(109131,525,"Upper western Daggermaw Ravine", "Kill and loot Ashmane Clefthoofs or Ashmane Bulls west of Stonefury Cliffs for Raw Clefthoof Meat.",meatTips,{URL(109131),"https://www.wowhead.com/npc=73234/ashmane-clefthoof"})
for _, id in ipairs({128500,109136,111557}) do
    Add(id,534,"Hulking Diretusks north of Vol'mar", "Kill and loot Hulking Diretusks north of Vol'mar for " .. items[id].itemName .. ".",meatTips,{"https://warcraft.wiki.gg/wiki/Hulking_Diretusk"})
end
Add(128500,534,"Diretusk Sow packs north of Vol'mar", "Kill and loot Diretusk Sows for Fel Ham; scout the boar packs north of Vol'mar.",meatTips,{"https://warcraft.wiki.gg/wiki/Diretusk_Sow",URL(128500)})
for _, point in ipairs({ {0.4842,0.6568,"Southern ground axebeak"},{0.4927,0.6259,"Tree-branch axebeaks"},{0.5055,0.6225,"Eastern ground axebeak"} }) do
    Add(128499,534,point[3],"Kill and loot Greater Axebeaks for Fel Egg; check birds on the ground and branches.",meatTips,{URL(128499)},point[1],point[2],"mob-farm")
end
Add(109133,539,"Darktide Roost rylaks", "Kill and loot eligible rylaks at Darktide Roost for the cooking material Rylak Egg.",{
    "Loot rylak corpses for the cooking reagent. The Giant Rylak Egg assault/achievement object is a different source and is not advertised as dropping the cooking item.",
    "Scout the live rylak packs on the island. No exact permanent cooking-egg spawn is asserted.",
},{URL(109133),"https://www.wowhead.com/object=235826/giant-rylak-egg"})
Add(109133,534,"Viletongue Rylaks in Tanaan", "Kill and loot Viletongue Rylaks for Rylak Egg attempts.",meatTips,{URL(109133)})
Inputs(110609,{109135,109132,109136},"Kill and loot the named area's eligible beasts, then skin them for Raw Beast Hide; meat is separate kill loot.",{
    "Skinning is required for hides. Loot the corpse first, then skin it; a meat drop does not itself award a hide.",
    "Lower Draenor Skinning skill may produce scraps instead. Beast availability and skinning results vary.",
},{URL(110609),"https://www.wow-professions.com/farming/raw-beast-hide-farming"})

-- Harvesting fragments use the parent resource's established alternatives.
for _, pair in ipairs({{109624,109124},{109625,109125},{109626,109126},{109627,109127},{109628,109128},{109629,109129},{109992,109118},{109991,109119}}) do
    items[pair[1]].spots = {}
    Inputs(pair[1],{pair[2]},"Harvest the parent resource here while your Draenor gathering training or skill still produces fragments; ten fragments combine into one whole resource.",{
        "Fragments are a training result, not a guaranteed extra item from a fully trained gatherer.",
        "Check your profession training before deliberately farming fragments; learning Draenor gathering changes the results.",
    },{URL(pair[1]),URL(pair[2])})
end
Inputs(116053,{109124,109125,109126,109127,109128,109129},"Gather Draenor herbs for bonus Draenic Seeds; seeds are bound and used at the Herb Garden.",{
    "Seeds are a gathering byproduct, not a separate plant to target.","Keep seeds for garden work orders; they cannot be sold on the Auction House.",
},{"https://warcraft.wiki.gg/wiki/Draenic_Seeds"})
Inputs(115508,{109118,109119},"Mine Draenor ore deposits for bonus Draenic Stone; the stone is bound and feeds garrison mine work orders.",{
    "Clear eligible deposits; stone is a byproduct rather than a dedicated node.","Turn spare stone into mine work orders; it is not an Auction House product.",
},{"https://warcraft.wiki.gg/wiki/Draenic_Stone"})
Inputs(120945,{109118,109119,109124,109125,109126,109127,109128,109129,110609},"Gather the named Draenor ore, herb or skinning source for possible Primal Spirits; skinning areas require killing, looting and skinning eligible beasts.",{
    "Primal Spirit is bound and is a random gathering byproduct; no source guarantees it on each attempt.","Use outdoor gathering alternatives alongside the original Tanaan choices. Garrison availability and yields differ.",
},{"https://warcraft.wiki.gg/wiki/Primal_Spirit"})
Inputs(114931,{109124,109125,109126,109127,109128,109129},"Gather the named Draenor herb, then mill it with Inscription for Cerulean Pigment. The herb node does not drop pigment directly.",{
    "All six standard Draenor herbs support milling for this pigment; compare herb availability before choosing a route.","Use stacks of five for ordinary Milling or the learned mass-milling recipe; inspect its reagent count. Pigment yield varies.",
    "A Cracked Draenic Mortar is a documented alternative for a character without Inscription; inspect the tool's current restrictions before preparing herbs.",
},{URL(114931),URL(114942),"https://www.wow-professions.com/guides/draenor-inscription-leveling"})
Inputs(110610,{110609},"Kill, loot and skin eligible Draenor beasts while your Skinning skill produces Raw Beast Hide Scraps.",{
    "Scraps favor lower Draenor Skinning skill; a fully trained skinner may get whole hides instead.","Ten scraps combine into one Raw Beast Hide. Scraps are not a guaranteed bonus to each whole-hide skin.",
},{"https://warcraft.wiki.gg/wiki/Raw_Beast_Hide_Scraps"})

local elemental = {
    {113261,{109124,109119,109118},"Alchemy Lab, Forge, Engineering Works or Enchanter's Study"},
    {113262,{109124,110609,111557,114931},"Alchemy Lab, Tannery, Tailoring Emporium or Scribe's Quarters"},
    {113263,{109119,109118,110609,114931},"Forge, Gem Boutique, Tannery or Scribe's Quarters"},
    {113264,{109118,109119,111557},"Gem Boutique, Engineering Works, Tailoring Emporium or Enchanter's Study"},
}
for _, entry in ipairs(elemental) do
    local id, inputs, buildings = entry[1], entry[2], entry[3]
    local tips = { "Bonus elements come from profession material crafts and matching building work orders, not elemental mobs.",
        "Gather the named input, perform any processing it needs, then supply a matching building: " .. buildings .. ".",
        "Sorcerous output is random. Alchemy transmutation is another option; inspect the learned recipe rather than assuming a free conversion." }
    Inputs(id,inputs,"Farm this input, then use the matching Draenor profession craft or work order for possible " .. items[id].itemName .. ". " .. buildings .. " are the relevant buildings.",tips,{WORK})
    Garrisons(id,buildings,"Queue matching profession-building work orders or use the relevant Draenor profession material craft for a possible " .. items[id].itemName .. " bonus.",tips,{WORK})
end

-- Enchanting sources distinguish gear loot, rare disenchant results and building output.
items[115504].spots = {}
items[113588].spots = {}
for _, id in ipairs({109693,115502,111245}) do
    for _, spot in ipairs(items[id].spots) do
        spot.farmAction = id == 109693 and "Loot eligible Draenor green or rare gear here, then disenchant it for Draenic Dust."
            or "Loot eligible Draenor rare gear here, then check its disenchant result for the selected Luminous Shard size; dust can be produced instead."
        spot.tips = Merge({ "These are gear-input areas, not direct shard or dust drops. Check the actual gear's disenchant table before scaling the farm." },spot.tips)
    end
end
for _, id in ipairs({115502,111245}) do
    Add(id,539,"Shadowmoon Burial Grounds rare gear","Run normal Shadowmoon Burial Grounds and disenchant eligible rare gear for Small Luminous Shard attempts" .. (id == 111245 and "; combine ten small shards into one Luminous Shard." or "."),{
        "This is a gear-input dungeon, not a direct shard drop. Dust may be the disenchant result instead.",
        "Respect instance limits and verify the exact gear result. Ten Small Luminous Shards combine into one Luminous Shard.",
    },{URL(115502),URL(111245)})
end
for _, id in ipairs({115504,113588}) do
    Garrisons(id,"Enchanter's Study",id == 115504 and "Submit Draenic Dust work orders at the Enchanter's Study and collect Fractured Temporal Crystals."
        or "Collect Fractured Temporal Crystals from the Enchanter's Study, then combine ten for a Temporal Crystal.",{
        "The building is a production source, not a mob farm. Build and unlock it on this character first.",
        "Work orders require Draenic Dust and take time. Check the current order tooltip and completed shipment before planning output.",
    },{WORK,URL(115504),URL(113588)})
    Inputs(id,{109693},"Farm eligible Draenor gear here, disenchant it for Draenic Dust, then submit dust work orders at the Enchanter's Study" .. (id == 113588 and " and combine ten Fractured Temporal Crystals into one Temporal Crystal." or " for Fractured Temporal Crystals."),{
        "This marker is a gear-input area. Work-order production happens afterward in your own garrison.",
        "Unlock the Enchanter's Study first. Work orders take time and require the stated dust input.",
    },{WORK,URL(115504),URL(113588)})
end
for _, raid in ipairs({{550,"Highmaul"},{543,"Blackrock Foundry"},{534,"Hellfire Citadel"}}) do
    Add(113588,raid[1],raid[2] .. " epic gear", "Enter " .. raid[2] .. ", loot eligible epic gear and disenchant it with an Enchanter for Temporal Crystals.",{
        "The map opens the raid's outdoor zone. Gear is the input; bosses do not directly drop Temporal Crystals.",
        "Loot lockouts apply. Choose a difficulty you can clear and check the actual item's disenchant result before destroying it.",
    },{URL(113588),"https://warcraft.wiki.gg/wiki/" .. raid[2]:gsub(" ","_")})
end
Garrisons(118472,"Level 3 Barn","Trap eligible elite beasts with the Deadly Iron Trap, then submit the cage at a Level 3 Barn for Savage Blood attempts.",{
    "Savage Blood is a Barn shipment result, not normal kill loot from the trapped beast.","Unlock the Level 3 Barn first. Skinning the corpse does not replace capturing the beast for a work order.",
},{"https://www.wowhead.com/guide/garrisons/buildings/guide-to-the-garrison-barn"})

-- Rotating archaeology sites are named choices with zone navigation, not permanent finds.
local digsites = {
    {109585,539,{"The Shimmer Moor"}},
    {109585,542,{"Apexis Excavation","Bloodmane Pridelands","Bloodmane Valley","Lithic's Rest","Pinchwhistle Point","Sethekk Hollow","Veil Zekk"}},
    {109585,535,{"Veil Shadar"}},
    {108439,525,{"Coldsnap Bluffs","Daggermaw Flows","Frostboar Drifts","Frostwind Crag","Frozen Lake","Grom'gar","Howling Plateau","Icewind Drifts","Lashwind Cleft","Stonefang Ridge","Southwind Cliffs","Wor'gol Ridge"}},
    {108439,543,{"Deadgrin"}},
    {108439,550,{"Ancestral Grounds","Burning Plateau","Drowning Plateau","Kag'ah","Razed Warsong Outpost","Ring of Trials","Rumbling Plateau"}},
    {108439,539,{"The Burial Fields","Anguish Fortress","Cursed Woods","Gloomshade","Shaz'gul"}},
    {109584,550,{"Highmaul Watchtower","Mar'gok's Overwatch","Overgrown Highmaul Road","Ruins of Na'gwa","Stonecrag Excavation"}},
    {109584,543,{"Overlook Ruins","Ruins of the First Bastion","The Broken Spine","Wildwood Wash Dam"}},
    {109584,542,{"The Writhing Mire"}},
    {109584,539,{"Umbrafen"}},
    {109584,535,{"Duskfall Island","Forgotten Ogre Ruin","Gordal Fortress","Zangarra"}},
}
for _, entry in ipairs(digsites) do
    for _, name in ipairs(entry[3]) do
        Add(entry[1],entry[2],name .. " digsite","Survey this matching-culture digsite only when it is active for your character; " .. items[entry[1]].itemName .. " is a possible keystone find.",{
            "Enable the Archaeology map overlay and follow the current site boundaries. This named site is a possible location, not a permanent spawn.",
            "Digsites rotate when cleared. Loot any spectral guardian that appears; it may provide another keystone attempt.",
        },{ARCHAEOLOGY,CYMRE})
    end
end
for _, reward in ipairs({{128313,"Ogrecoming Adversity"},{128314,"Blizzard Convention"}}) do
    Garrisons(reward[1],"Town Hall mission table","Check your follower mission table for " .. reward[2] .. "; complete the mission when offered for " .. items[reward[1]].itemName .. ".",{
        "The mission's destination is not a place to grind this reward. You obtain it through the mission table.",
        "Offers are random and progression-gated; inspect the displayed follower requirements. Keep the tradeable reward unconsumed if selling.",
    },{URL(reward[1]),"https://warcraft.wiki.gg/wiki/" .. reward[2]:gsub(" ","_")})
end
local lumberTips = { "Complete the housing lumber introduction and follow axe-marked harvestable trees. Housing lumber differs from old Garrison Lumber Mill timber.",
    "These are reported scouting areas, not fixed tree spawns. Availability varies; Shadowmoon Lumber is Warband-bound.",
    "Old advice to trade Outland lumber predates Draenor harvesting returning in the Midnight pre-patch." }
for _, area in ipairs({{550,"Spirit Woods around Oshu'gun"},{588,"Ashran woodland"},{535,"Talador woodland"},{539,"Shadowmoon woodland"},{542,"Spires woodland"}}) do
    Add(251766,area[1],area[2],"Scout harvestable housing trees in this Draenor area for Shadowmoon Lumber.",lumberTips,{
        URL(251766),"https://www.wowhead.com/news/shadowmoon-lumber-returned-to-warlords-of-draenor-zones-in-the-midnight-pre-380372",
    })
end

for _, id in ipairs({109124,109125,109126,109127,109128,109129,116053}) do
    Garrisons(id,"Herb Garden",id == 116053 and "Harvest your unlocked Herb Garden for Draenic Seeds; collect the bound seeds for garden work orders."
        or "Harvest your unlocked Herb Garden for " .. items[id].itemName .. "; assign a Herbalism follower where available to select the planted herb.",{
        "The personal garden is a daily alternative. Complete its unlock and check the follower's planting options.",
        "The selected herb is not guaranteed from every random plant or shipment. Check the garden state on this character.",
    },{PRESET})
end
for _, id in ipairs({109118,109119,115508}) do
    Garrisons(id,"Lunarfall Excavation / Frostwall Mines",id == 115508 and "Mine the unlocked garrison deposits for Draenic Stone and use it for mine work orders."
        or "Mine your unlocked garrison deposits and collect mine work orders for Draenor ore; inspect the shipment for " .. items[id].itemName .. ".",{
        "This is a personal daily mine alternative. Upgrade and clear the mine as your progression allows.",
        "Draenic Stone is bound and feeds work orders; it is not a tradeable stone node to farm separately.",
    },{PRESET})
end

for id in pairs(base) do
    local item, count, navigation, pins = items[id], 0, 0, 0
    for _, spot in ipairs(items[id].spots) do
        count, navigation, pins = count + 1, navigation + (spot.mapOnly and 1 or 0), pins + #(spot.coords or {})
    end
    audit.items[id] = { mapOptionCount = count, navigationCount = navigation, pinCount = pins }
end
NS.DraenorBaseMaterialMapAudit = audit
