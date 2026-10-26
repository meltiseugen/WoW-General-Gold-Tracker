local _, NS = ...

-- Item-by-item research: docs/research/legion-base-map-*-2026-10-21.*.
-- Loaded after CatalogGathering. Only non-composed Legion records are copied/enriched.
if NS.LegionBaseMaterialMapAudit then return end
local items, base = NS.MaterialFarmingSpots.items, {}
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function Merge(...)
    local result, seen = {}, {}
    for _, list in ipairs({...}) do
        for _, value in ipairs(list) do
            if not seen[value] then result[#result + 1], seen[value] = value, true end
        end
    end
    return result
end
local function URL(id) return "https://www.wowhead.com/item=" .. id end
local function Key(value) return tostring(value or ""):lower():gsub("[^%w]", "") end
local maps = {
    [627] = "Dalaran (Broken Isles)", [628] = "Dalaran Sewers", [630] = "Azsuna",
    [634] = "Stormheim", [641] = "Val'sharah", [646] = "Broken Shore", [650] = "Highmountain",
    [680] = "Suramar", [830] = "Krokuun", [882] = "Eredath", [885] = "Antoran Wastes",
    [114] = "Borean Tundra", [104] = "Shadowmoon Valley (Outland)",
    [120] = "The Storm Peaks", [226] = "Gnomeregan", [390] = "Vale of Eternal Blossoms",
}
local mapIDs = {}
for id, name in pairs(maps) do mapIDs[Key(name)] = id end
mapIDs.dalaran, mapIDs.valsharah, mapIDs.map882, mapIDs.map885 = 627, 641, 882, 885
local audit = { researchedAt = "2026-10-21", scope = "Legion base Materials; composed excluded", items = {}, rejectedSpots = {} }
local function DefaultAction(row, item)
    local tag = row.tag
    if tag == "Herb" then return "Gather " .. item.itemName .. " with Legion Herbalism; follow the selected route's requirements." end
    if tag == "Ore" then return "Mine " .. item.itemName .. " with Legion Mining; follow the selected route's requirements." end
    if tag == "Meat" or tag == "Egg" or tag == "Feather" then return "Defeat and loot the named creatures for a chance at " .. item.itemName .. "." end
    if tag == "Cloth" then return "Defeat and loot the named humanoid packs for " .. item.itemName .. "; Tailoring improves cloth collection." end
    if tag == "Leather" or tag == "Hide" then return "Kill, fully loot, then skin the named creatures for " .. item.itemName .. "." end
    if tag == "Claw" or tag == "Tooth" then return "Loot and skin eligible Broken Isles beasts for a chance at " .. item.itemName .. "." end
    if tag == "Fish" then return "Fish the named waters for " .. item.itemName .. "; move between available schools." end
    return "Follow the acquisition steps below for " .. item.itemName .. "."
end
for _, row in ipairs(NS.FarmingItems.items) do
    if row.expansion == "legion" and (type(row.components) ~= "table" or #row.components == 0) then
        local id = row.itemID
        base[id] = row
        local item = Copy(items[id] or {itemID = id, itemName = row.itemName, expansion = "legion"})
        items[id] = item
        item.researchedAt = audit.researchedAt
        item.sourceUrls = Merge(item.sourceUrls or {}, {URL(id)})
        local spots = {}
        for _, spot in ipairs(item.spots or {}) do
            spot.mapID = tonumber(spot.mapID) or mapIDs[Key(spot.mapName)]
            if maps[spot.mapID] then
                spot.mapName = maps[spot.mapID]
                spot.sourceUrls = Merge(spot.sourceUrls or {}, item.sourceUrls)
                spot.tips = Merge(spot.tips or {}, item.tips or {})
                spot.farmAction = spot.farmAction or DefaultAction(row, item)
                spots[#spots + 1] = spot
            else
                audit.rejectedSpots[#audit.rejectedSpots + 1] = {itemID = id, spotID = spot.id, mapName = spot.mapName}
            end
        end
        item.spots = spots
    end
end
local FISHING = "https://www.wowhead.com/guide/legion-fishing"
local JEWELS = "https://www.wowhead.com/guide/legion-jewelcrafting-guide-4257"
local INSCRIPTION = "https://www.wow-professions.com/guides/legion-inscription-leveling"
local ARCHAEOLOGY = "https://www.wowhead.com/guide/legion-archaeology"
local function Add(id, mapID, location, action, tips, sources, x, y, kind)
    if not base[id] then return end
    local item = items[id]
    local spot = {
        id = "legion-base-" .. id .. "-" .. mapID .. "-" .. Key(location),
        mapID = mapID, mapName = assert(maps[mapID]), location = location,
        dropdownLabel = maps[mapID] .. ": " .. location, farmAction = action,
        tips = Copy(tips), sourceUrls = Merge({URL(id)}, sources or {}),
        isRoute = false, routeType = kind or "source-area-guidance", confidence = "medium", inGameTested = false,
        source = "Retail item, source guide or named player report; area navigation where no fixed pin is supported",
        density = "Variable; availability and character progression apply",
        dropDifficulty = "Follow the acquisition steps and requirements; no measured hourly yield.",
        coords = {}, mapOnly = not (x and y),
    }
    if x and y then spot.coords = {{x = x, y = y, label = location}} end
    item.spots[#item.spots + 1] = spot
    item.sourceUrls = Merge(item.sourceUrls, spot.sourceUrls)
end

-- Additional named gathering/kill areas. These are scouting areas, not invented spawns.
local mobAreas = {
    {124113,630,"Young Bloodgazers and Bloodgazer Nest-Keepers",0.3557,0.0566,"stonehide-leather"},
    {124113,650,"Young Snowfeathers and Snowfeather Nest-Keepers",0.3513,0.2193,"stonehide-leather"},
    {124113,634,"Saberfang Worg habitat",nil,nil,"stonehide-leather"},
    {124113,630,"Llothien Prowler habitat",nil,nil,"stonehide-leather"},
    {124115,630,"Spikebacked Scuttlers near the Val'sharah border",nil,nil,"stormscale"},
    {124118,650,"The Witchwood bears",nil,nil,"fatty-bearsteak"},
    {124121,650,"Northern Highmountain coast around 35,18",0.35,0.18,"wildfowl-egg"},
    {151567,830,"Krokuun humanoid respawn camps",nil,nil,"lightweave-cloth"},
}
for _, area in ipairs(mobAreas) do
    local id = area[1]
    Add(id,area[2],area[3],DefaultAction(base[id],items[id]),{
        "Scout the named habitat and loot your kills. Move to another listed area when competition or quest phasing makes it sparse.",
        "For skinning, wait until every player who tagged the creature has looted. For cloth, use a tailor where possible.",
    },{"https://www.wow-professions.com/farming/" .. area[6] .. "-farming",URL(id)},area[4],area[5],"mob-source")
end

local extraDrops = {
    {124119,641,"Goats outside Bradensbrook"},
    {124119,650,"Spinetusk Piglets at Cliff's Edge",0.3645,0.3793},
    {124119,634,"Plains Runehorn and calves",0.47,0.33},
    {124119,650,"Cursed and Pinerock Elderhorn near Nesingwary's Retreat"},
    {124117,630,"Llothien Prowlers north of Nar'thalas Academy",0.55,0.28},
    {124120,630,"Azsuna Mana Wyrms at El'dranil Shallows",0.54,0.37},
    {124120,680,"Thicket Manahunters",0.60,0.42},
    {124120,680,"Leyline Prowlers inside Ley Station Moonfall"},
    {124115,630,"Cliffwing Hippogryphs east of Illidari Stand",0.475,0.465},
    {124115,641,"Lytheron Gloomscales on Gloomscale Coast"},
    {124115,680,"River crocolisks by the bridge",0.34,0.41},
    {124115,634,"Crimson Rockshells in Citrine Bay"},
}
for _, area in ipairs(extraDrops) do
    Add(area[1],area[2],area[3],DefaultAction(base[area[1]],items[area[1]]),{
        "This habitat or coordinate is from an individual item-page farming report. Scout nearby packs; old yield and respawn claims have not been remeasured.",
        "Loot the named creatures, and skin only eligible corpses after all taggers have looted. A reported drop source does not guarantee each kill.",
    },{URL(area[1])},area[4],area[5],"reported-mob-source")
end

-- Keep each existing water anchor as a separate selectable fishing location.
-- Do not turn isolated fishing water points into connected walking routes.
for id, row in pairs(base) do
    if row.tag == "Fish" or row.tag == "Fishing Bait" or row.tag == "Fishing Transmog" then
        local split = {}
        for _, original in ipairs(items[id].spots) do
            if #(original.coords or {}) <= 1 then split[#split + 1] = original
            else
                for index, coord in ipairs(original.coords) do
                    local spot = Copy(original)
                    spot.id = original.id .. "-water-" .. index
                    spot.location = coord.label or original.location
                    spot.dropdownLabel = spot.mapName .. ": " .. spot.location
                    spot.coords, spot.isRoute = {Copy(coord)}, false
                    split[#split + 1] = spot
                end
            end
        end
        items[id].spots = split
    end
end
Add(124111,680,"Irongrove Retreat river confluence","Fish Runescale Koi schools around the river junction by Irongrove Retreat.",{
    "Circle the confluence beside Moonguard Stronghold and check both river branches for new schools.",
},{URL(124111)},0.25,0.28,"fishing-source")
for _, mapID in ipairs({630,634,641,650,680}) do
    Add(124112,mapID,"Great Sea off the " .. maps[mapID] .. " coast","Fish ocean water and Black Barracuda schools off this coast.",{
        "For ocean rare-bait chains, move offshore until the minimap says The Great Sea. Inland zone fish use different bait tables.",
        "Schools move or disappear when fished out; use water walking or a raft where available.",
    },{FISHING,URL(124112)})
    Add(133607,mapID,"Open water in " .. maps[mapID],"Fish Broken Isles open water for Silver Mackerel as a common catch.",{
        "Silver Mackerel can accompany the zone fish. A school is useful for its named species but is not required for this common catch.",
    },{FISHING,URL(133607)})
end
for _, area in ipairs({{627,"Dalaran fountain"},{627,"Margoss's Retreat pond"},{628,"Underbelly fishing waters"}}) do
    Add(138967,area[1],area[2],"Fish " .. area[2] .. " for Big Fountain Goldfish.",{
        "Use Broken Isles Dalaran. This food fish is separate from fountain coins and the Drowned Mana reputation item.",
    },{URL(138967),FISHING})
end

-- Snapshot only the normalized, independently owned input spots, so chaining
-- never pulls in a later derivative's maps or mutates the original ore/herb route.
local inputs = {}
for id in pairs(base) do inputs[id] = Copy(items[id].spots) end
local function Inputs(id, inputIDs, action, tips, sources)
    if not base[id] then return end
    local item = items[id]
    item.mapInputItemIDs = Merge(item.mapInputItemIDs or {}, inputIDs)
    for _, inputID in ipairs(inputIDs) do
        for _, original in ipairs(inputs[inputID] or {}) do
            local spot = Copy(original)
            spot.id = "legion-base-" .. id .. "-input-" .. inputID .. "-" .. original.id
            spot.location = items[inputID].itemName .. " source - " .. original.location
            spot.dropdownLabel = spot.mapName .. ": " .. spot.location
            spot.farmAction = action
            spot.isRoute, spot.routeType = false, "input-source-guidance"
            spot.inGameTested = false
            spot.sourceUrls = Merge({URL(id),URL(inputID)},sources or {},original.sourceUrls or {})
            spot.tips = Merge(tips,original.tips or {},{
                "Pins show the input's source. Processing and random outputs do not have independent resource nodes.",
            })
            spot.density = "Input availability varies; the selected processing output is random"
            spot.dropDifficulty = "Collect the stated input, then perform the required profession action."
            item.spots[#item.spots + 1] = spot
            item.sourceUrls = Merge(item.sourceUrls,spot.sourceUrls)
        end
    end
end
for _, id in ipairs({124438,124439}) do
    Inputs(id,{124113,124115},"Kill, fully loot and skin eligible Broken Isles beasts for a chance at " .. items[id].itemName .. ".",{
        "These are bonus loot or skinning reagents. Prioritize the named beasts and loot every corpse rather than expecting a separate claw or tooth node.",
    },{URL(id)})
end
local function Timewalking(id, delivery)
    Add(id,627,"Aridormi at Krasus' Landing - Legion Timewalking only","During Legion Timewalking, check Aridormi's " .. delivery .. " for a chance at " .. items[id].itemName .. ".",{
        "Aridormi is event-only. Check the calendar and the bag's current contents before spending Timewarped Badges; the selected item is not guaranteed.",
    },{"https://www.wowhead.com/guide/events/legion-timewalking-weekly-bonus-event-guide","https://warcraft.wiki.gg/wiki/" .. delivery:gsub(" ","_")},0.688,0.496,"event-vendor-cache")
end
local epic = {151718,151719,151720,151721,151722,151579}
for _, id in ipairs(epic) do
    Inputs(id,{151564},"Mine Empyrium on this Argus route, then use Legion Prospecting for a chance at " .. items[id].itemName .. ".",{
        "These are uncut Argus epic gems. Leystone and Felslate are sources for the earlier Legion gems, not these Argus gems.",
        "Prospecting consumes five ore; Mass Prospect Empyrium consumes twenty. Gem Chips can replace a gem result, and a particular color is never guaranteed.",
        "Unlock Argus travel first. Retain the route's cave, terrain and conditional-source instructions.",
    },{JEWELS,"https://www.wowhead.com/spell=247761/mass-prospect-empyrium"})
    Add(id,830,"Maras aboard the Vindicaar - lower deck","Board the Argus Vindicaar and exchange 10 Primal Sargerite with Maras for one " .. items[id].itemName .. ".",{
        "Maras stands downstairs by the profession trainers. Complete The Prime Exchange if offered; his stock requires the Argus version of the ship.",
        "This option opens Krokuun for access to the ship, not an outdoor vendor pin. Do not use ship-floor coordinates on the zone map.",
    },{"https://www.wowhead.com/npc=129674/maras","https://warcraft.wiki.gg/wiki/Maras"})
    Timewalking(id,"Broken Isles Gem Delivery")
end
for id = 130172,130183 do
    -- The two old Suramar-only entries include historical chip-color advice.
    -- Replace them with the full ore-source lists and current acquisition notes.
    items[id].spots = {}
    Inputs(id,{123918,123919},"Mine Leystone Ore or Felslate, then use Legion Prospecting for a chance at " .. items[id].itemName .. ".",{
        "Prospect five ore at a time, or use the corresponding Mass Prospect recipe. A named gem is not guaranteed in a batch.",
        "Leystone commonly supplies uncommon gems; Felslate is the stronger rare-gem input. Compare ore and gem prices before processing.",
        "Old gem-chip color prediction guides describe historical behavior; do not assume they guarantee the next gem in current Retail.",
    },{JEWELS,"https://www.wowhead.com/spell=31252/prospecting"})
    Timewalking(id,"Broken Isles Gem Delivery")
end
Inputs(129100,{123918,123919,151564},"Mine the selected Legion ore and prospect it for Gem Chips alongside random gems.",{
    "Keep the grey crafting reagent Gem Chip (129100); colored chips are different items. Prospecting is random rather than a fixed recipe for this chip.",
},{JEWELS,URL(129100)})

local herbs = {124101,124102,124103,124104,124105,124106,151565}
for _, id in ipairs({129032,129034}) do
    Inputs(id,herbs,"Gather the selected Legion herb, then mill it with Legion Inscription for " .. items[id].itemName .. ".",{
        "Milling consumes herbs; pigments are processing results rather than separate plants. Use the matching Mass Mill recipe once learned.",
        "Felwort is a strong Sallow input but its gathering is world-quest gated. Dreamleaf can produce Nightmare Pods; open these for more pigment.",
        "Astral Glory is another option after unlocking Argus. Compare input prices and avoid treating historical sample yields as a guaranteed return.",
    },{INSCRIPTION,URL(129032),URL(129034)})
end
for _, pair in ipairs({{129284,124101},{129285,124102},{129286,124103},{129287,124104},{129288,124105},{129289,124106}}) do
    Inputs(pair[1],{pair[2]},"Gather " .. items[pair[2]].itemName .. " with Herbalism for a chance at " .. items[pair[1]].itemName .. ".",{
        "Seeds are bonus harvests. Planting consumes a seed in Fertile Soil; it does not farm a new seed directly.",
        "Keep Felwort's world-quest requirements. Check technique ranks and bags before making a seed-specific trip.",
    },{URL(pair[1]),URL(pair[2])})
end
Inputs(128304,{124101,124102,124103,124104,124105},"Gather Broken Isles herbs for Yseralline Seeds as a secondary harvest.",{
    "These common seeds are a bonus from normal Broken Isles herb gathering, not the species-specific seeds used at Fertile Soil.",
},{URL(128304)})

local baitGroups = {
    {124107,{133701,133702,133703,133704}},
    {124108,{133705,133707,133708}},
    {124109,{133709,133710,133711,133712}},
    {124110,{133713,133714,133715,133716}},
    {124111,{133717,133719,133720}},
    {124112,{133721,133722,133723,133724,133795}},
}
local baitActions = {
    [133701]="Fish Azsuna freshwater for Skrog Toenail; carrying it attracts a Salteye Skrog-Hunter.",
    [133702]="Fish Skrog Toenail in Azsuna, wait for the attracted Salteye Skrog-Hunter, then kill and loot it for Aromatic Murloc Slime.",
    [133703]="Fish Azsuna freshwater for Pearlescent Conch; keep it unused if selling the bait.",
    [133704]="Fish Azsuna freshwater for Rusty Queenfish Brooch; using it reveals Ghostly Queenfish schools.",
    [133705]="Fish Val'sharah freshwater for Rotten Fishbone; using it attracts the druid who helps catch Ancient Mossgill.",
    [133707]="Fish Val'sharah freshwater for Nightmare Nightcrawler, the bait for Terrorfin.",
    [133708]="Fish Val'sharah freshwater for Drowned Thistleleaf; using it helps catch Thorned Flounder.",
    [133709]="Fish Highmountain freshwater for Funky Sea Snail; its timed effect attracts Bitestone Fishbrul.",
    [133710]="Fish Funky Sea Snail in Highmountain, wait for Bitestone Fishbrul, then kill and loot him for Salmon Lure.",
    [133711]="Fish Highmountain freshwater for Swollen Murloc Egg; using it attracts a murloc that helps catch Mountain Puffer.",
    [133712]="Fish Highmountain freshwater for Frost Worm, the bait for Coldriver Carp.",
    [133713]="Fish Stormheim water for Moosehorn Hook; fish while its effect is active to catch Silverscale Minnow.",
    [133714]="Apply Moosehorn Hook and fish Stormheim water for Silverscale Minnow; this second-stage bait attracts Thundering Stormray.",
    [133715]="Fish Stormheim water for Ancient Vrykul Ring; using it reveals Oodelfjisk schools.",
    [133716]="Fish Stormheim water for Soggy Drakescale, the bait for Graybelly Lobster.",
    [133717]="Fish Suramar freshwater for Enchanted Lure, the bait for Magic-Eater Frog.",
    [133719]="Fish Suramar freshwater for Sleeping Murloc; release it and collect its Seerspine Puffer.",
    [133720]="Fish Suramar freshwater for Demonic Detritus, the bait for Tainted Runescale Koi.",
    [133721]="Fish the Great Sea off the Broken Isles for Message in a Beer Bottle; open it only when you want the Axefish Lure.",
    [133722]="Fish Message in a Beer Bottle from the Great Sea, then open it for Axefish Lure.",
    [133723]="Fish Broken Isles ocean water for Stunned, Angry Shark; release it promptly and defeat the Landlocked Shark for Seabottom Squid.",
    [133724]="Fish Broken Isles ocean water for Decayed Whale Blubber; using it attracts Ravenous Flies.",
    [133795]="Fish Decayed Whale Blubber from Broken Isles ocean water, use it, then loot the attracted flies for Ravenous Fly.",
}
for _, group in ipairs(baitGroups) do
    for _, id in ipairs(group[2]) do
        -- Replace the duplicated legacy water list with the full correct-species list.
        items[id].spots = {}
        Inputs(id,{group[1]},baitActions[id],{
            "Use Arcane Lure when seeking rare bait. Check Unique limits in bags and bank before trying for another.",
            "Some items require a prior bait, a buff expiring, or a summoned creature; follow the action instead of expecting a direct fishing catch.",
        },{FISHING,URL(id)})
        for _, spot in ipairs(items[id].spots) do
            spot.tips = Merge(spot.tips, items[id].tips or {})
            if id == 133723 then spot.tips = Merge(spot.tips,{"This shark expires after one minute in real time. Release it immediately rather than treating it as ordinary storable bait."}) end
        end
    end
end
for _, id in ipairs({139405,139406,139407,139408}) do
    items[id].spots = {}
    Inputs(id,{124107,124108,124109,124110,124111,124112},"Fish Broken Isles waters with Underlight Angler's Better Luck Next Time trait for a chance at " .. items[id].itemName .. ".",{
        "This is a rare fishing transmog side catch, not guaranteed by a particular school or bait. Unlock the artifact and the required trait first.",
        "Leave the boots unequipped if you intend to sell them. This map gives suitable fishing water, not a dedicated boot spawn.",
    },{FISHING,"https://www.wowhead.com/guide/the-legion-fishing-artifact-underlight-angler-world-of-warcraft-4505"})
end

-- World-quest sources need explicit availability; their markers are not permanent farms.
for _, area in ipairs({{630,"Wardens' Redoubt offshore",0.2986,0.5826},{630,"Southern Azsuna",0.416,0.700},
    {650,"Northern Highmountain",0.4378,0.2523},{650,"Patrol near the harpy run",0.4248,0.4208},
    {650,"Summitcrest mountain",0.480,0.720},{641,"Val'sharah reported quest area",0.4643,0.4286},
    {680,"Eastern Suramar",0.7365,0.4746},{680,"Northwestern Suramar",0.3633,0.2944},
    {634,"Southern Stormheim cave entrance",0.6214,0.7495},{634,"Northern Stormheim",0.5807,0.2047}}) do
    Add(124116,area[1],area[2] .. " - Felhide WQ only","When its Skinning world quest is active, kill and skin the Felhide Gargantuan here.",{
        "Requires Skinning and an eligible active profession world quest. A sleeping creature outside its quest may be unskinnable and has no normal loot.",
        "Markers are reported spawn or cave-entrance anchors. Check the current world-quest map before travelling.",
    },{URL(124116),"https://www.wowhead.com/npc=103675/felhide-gargantuan"},area[3],area[4],"conditional-world-quest")
end
items[133680].spots = {}
for _, area in ipairs({{630,"Well-Fed Lion Seal"},{634,"Well-Fed Musken"},{641,"Well-Fed Bear"},{650,"Well-Fed Ironhorn Bull"},{680,"Baconlisk"}}) do
    Add(133680,area[1],area[2] .. " - Slab of Bacon WQ","Complete an active Slab of Bacon cooking world quest by killing and looting " .. area[2] .. ".",{
        "The cooking material is the quest reward, not an unrestricted repeatable meat drop. Check Cooking requirements and the active quest marker.",
        "Several variants exist within the same zone. This choice opens the zone; follow today's quest rather than a permanent spawn pin.",
    },{"https://www.wowhead.com/quest=41261/slab-of-bacon"})
end

-- Processed materials and enchantment-gated caches retain their actual source action.
for _, id in ipairs({124440,124441,124442}) do
    local rarity = id == 124440 and "uncommon" or (id == 124441 and "rare" or "epic")
    for _, spot in ipairs(items[id].spots) do
        spot.farmAction = "Obtain eligible Legion " .. rarity .. " equipment from this source, then disenchant it for " .. items[id].itemName .. "."
        spot.tips = Merge(spot.tips,{"Check that the item belongs to Legion before disenchanting. Modern scaled and Timewalking gear can use a different loot or reagent table."})
    end
    for _, dungeon in ipairs({{680,"The Arcway entrance",0.418,0.607},{680,"Court of Stars entrance",0.507,0.655}}) do
        Add(id,dungeon[1],dungeon[2],"Run the legacy dungeon for eligible Legion " .. rarity .. " equipment, then disenchant it for " .. items[id].itemName .. ".",{
            "Boss and trash loot rarity differ by difficulty. Choose eligible gear; epic crystals do not come from ordinary green equipment.",
            "Observe instance lockouts. The marker is the entrance, not the location of a reagent drop inside.",
        },{"https://www.wowhead.com/guide/legion-enchanting","https://www.wowhead.com/zone=7855/the-arcway"},dungeon[3],dungeon[4],"disenchant-input")
    end
    Timewalking(id,"Broken Isles Enchantment Delivery")
end
Inputs(124441,{124442},"Obtain Legion Chaos Crystals, then use Chaos Shatter to turn one into two Leylight Shards.",{
    "Requires the Chaos Shatter formula, unlocked through Argussian Reach reputation. This is a profession conversion after collecting crystals.",
},{URL(124441),"https://www.wowhead.com/guide/legion-enchanting"})
Inputs(124440,{124441},"Obtain Legion Leylight Shards, then use Ley Shatter to turn one into three Arkhana.",{
    "Learn Ley Shatter from its formula first. The source markers locate shard inputs; the shatter can be performed wherever the profession allows.",
},{URL(124440),"https://www.wowhead.com/guide/legion-enchanting"})
Inputs(144329,{124437},"With Boon of the Builder active on eligible shoulders, kill Legion outdoor enemies and open Sprocket Containers for Hardened Felglass.",{
    "Engineers obtain Boon of the Builder through Hobart Grapplehammer in Dalaran. Equip the enchanted shoulders before killing mobs.",
    "The container is the source of Felglass; cloth drops merely identify dense outdoor mob areas. Do not expect Felglass without the enchant.",
    "Check the enchant's item-level restriction on your shoulders. Cache drops are intermittent; no hourly yield is promised.",
},{"https://www.wowhead.com/quest=46119/boon-of-the-builder","https://warcraft.wiki.gg/wiki/Hardened_Felglass"})
Inputs(124124,{123918,123919,124101,124102,124103,124104,124105,124113,124115},"Gather or skin eligible Broken Isles resources for a chance at Blood of Sargeras.",{
    "This reagent is soulbound. Gathering technique ranks matter; unlock the relevant higher-rank technique before farming for the byproduct.",
    "World quests and Order Hall missions can offer alternatives; inspect actual rewards rather than assuming a guaranteed node drop.",
},{URL(124124)})
Inputs(151568,{151564,151565,151566},"Gather eligible Argus resources for a chance at Primal Sargerite.",{
    "Empyrium deposits require the Rank 2 mining technique to yield Primal Sargerite. Unlock the relevant gathering techniques first.",
    "The reagent is soulbound. Inspect Argus world-quest rewards before grinding; ore, herbs or leather are the primary harvests.",
},{URL(151568)})

-- Named rotating digsites: culture and zone are explicit; no fixed find pins.
local digsites = {
    {130903,680,{"Meredil","North-Western Suramar City","The Gates of the City","Southern Ambervale","Koralune Estate","Moonwhisper Gulch","Crimson Thicket","Northern Moonwell Retreat"}},
    {130903,630,{"Nor'Danil Wellspring","Temple of a Thousand Lights","The Ruined Sanctum","Llothien","Old Coast Path","Ruins of Zarkhenar","The Tidal Marsh","Garden of Elune"}},
    {130904,650,{"Northern Snowblind Mesa","The Witchwood","Fields of An'she","Screeching Crag","Darkfeather Valley","The Haglands","Bloodhunt Highland","Sepulcher of the Sky","Dragon's Falls","Prowler's Scratch","Whitewater Wash","Pinerock Basin"}},
    {130905,630,{"Grey Shoals","Llothien Highlands","Legion Camp: Chaos","Farondale","Rhut'van Passage","Mak'rana","Northern Watcher Isle","Southern Watcher Isle"}},
    {130905,641,{"Bradensbrook","Dreadroot","The Crescent Vale","Shala'nir","The Wildwood","Thas'talah","Wretched Hollow"}},
    {130905,634,{"Amberfall Mesa","Northern Helmouth Shallows","Citrine Bay","Warden's Bluff","Skold-Ashil","South Helmouth Shallows","Stormdrake Peaks","Aggramar's Vault"}},
}
for _, group in ipairs(digsites) do
    for _, name in ipairs(group[3]) do
        Add(group[1],group[2],name .. " digsite","Survey this matching-culture digsite when active for a chance at " .. items[group[1]].itemName .. ".",{
            "Enable Show Digsites and use Survey inside the current site boundaries. Legion culture availability rotates with the archaeology schedule.",
            "The selected name is a possible site, not a permanent find. Loot archaeology spirits and inspect any special object uncovered during Survey.",
        },{ARCHAEOLOGY,"https://www.cymre.com/2016/06/23/legion-archaeology/"})
    end
end

-- Tradeable mana consumables differ from currency-only Arcwine and blossoms.
for _, id in ipairs({139786,139890}) do
    for _, name in ipairs({"Moonguard Stronghold mana-container sweep","Suramar eastern underwater trench","Suramar/Azsuna border at Sundered Shoals"}) do
        Add(id,680,name,"Loot Ancient Mana Crystal objects and Ancient Mana Chunks for a chance at the tradeable " .. items[id].itemName .. ".",{
            "Keep the inventory consumable unused if selling. Arcwine, blossoms and direct currency pickups are not interchangeable with this item.",
            "Container spawns vary. Inspect the object name and loot rather than assuming every ancient-mana icon yields the saleable crystal or gem.",
        },{"https://www.wowhead.com/object=252774/ancient-mana-crystal","https://www.wowhead.com/object=251416/ancient-mana-chunk"})
    end
end

-- Legion engineering uses several earlier-expansion locations, not Argus mobs.
Add(140781,226,"Launch Bay and Engineering Labs","Kill and loot Gnomeregan mechanical creatures for X-87 Battle Circuits.",{
    "Clear Mechanized Sentries, Arcane Nullifiers and Mechano-Frostwalkers in the later dungeon sections. Reset only within the instance limit.",
    "Unique (50): check bags and bank before another run. These components bind on pickup.",
},{URL(140781)})
Add(140782,120,"Ulduar entrance - Mimiron inside","Enter Ulduar and defeat Mimiron for a chance at Neural Net Detangler.",{
    "Use the internal Ulduar teleporter when accessible. This is a legacy raid boss drop with a lockout, not a Storm Peaks outdoor mob farm.",
},{URL(140782)})
Add(140783,390,"Siege of Orgrimmar entrance - Iron Juggernaut inside","Enter Siege of Orgrimmar and loot Iron Juggernaut for a chance at Predictive Combat Operations Databank.",{
    "The component is not guaranteed. Follow the raid's boss-access requirements and lockout; old comments about mandatory two-player Galakras tactics may be outdated.",
},{URL(140783)})
for _, name in ipairs({"Shadowhoof satyrs outside Black Temple","Doomwalker spawn outside Black Temple"}) do
    Add(140784,104,name,"Kill and loot Shadowhoof Summoners or nearby satyrs outside Black Temple for Fel Piston Stabilizer; Doomwalker is another source.",{
        "Use Outland Shadowmoon Valley, not Draenor. The satyr alternative avoids waiting for the outdoor boss.",
        "The stabilizer is Unique and soulbound; check bags and bank before farming more.",
    },{URL(140784),"https://warcraft.wiki.gg/wiki/Fel_Piston_Stabilizer"})
end

-- Quest-only legendary inputs stay outside Composed because the existing catalog
-- has no deterministic components for them. Explain the actual gated steps.
for _, id in ipairs({146710,146711,146712,146713,146714}) do
    Add(id,646,"Eliezer Hammerbeard at Deliverance Point","Follow Eliezer Hammerbeard's profession legendary quest chain for " .. items[id].itemName .. ".",{
        "This is a bound quest reward, not a regular mob drop. Complete the profession and dungeon prerequisites and inspect current quest availability.",
        "Use the final quest supplies at the required station, then return the completed case or satchel to Eliezer for the actual reagent.",
    },{URL(id),"https://www.wowhead.com/guide/a-guide-to-legion-legendaries"})
end
for _, id in ipairs({146710,146711}) do
    Add(id,680,"Queen's Grace Loom","During Starweave and Shadowcloth, use Legendary Tailor's Materials at the Queen's Grace Loom, then turn in the satchel.",{
        "Unlock The Queen's Grace Loom and the building's teleporting orb first. The loom is upstairs after using that orb.",
    },{"https://www.wowhead.com/quest=46683/starweave-and-shadowcloth"},0.405,0.695,"quest-station")
end
Add(146712,650,"Hrul Sharphoof's dwelling at Thunder Totem","During Wisp-Touched Elderhide, use the Legendary Tanner's Kit at the heirloom hides in Hrul's dwelling.",{
    "The quest calls him Hrul Sharptooth; the NPC is Hrul Sharphoof. Follow the quest and return the bag to Eliezer for the reagent.",
},{"https://www.wowhead.com/quest=46689/wisp-touched-elderhide","https://warcraft.wiki.gg/wiki/Hrul_Sharphoof"})
Add(146713,630,"Celea beside the pond","During Prime Wardenscale, use Legendary Wardenscale Supplies beside Celea and return the completed box to Eliezer.",{
    "Finish all prerequisite legendary leatherworking quests. Merely killing creatures beside Celea does not produce this reagent.",
},{"https://www.wowhead.com/quest=46695/prime-wardenscale"},0.474,0.442,"quest-station")
Add(146714,650,"Firmament Stone at Ironhorn Enclave","During Hammer of Forgotten Heroes, use Legendary Blacksmithing Supplies at the Firmament Stone, then return the carrying case.",{
    "Complete the earlier hammer and armor collection quests. The station alone cannot generate the reagent without those quest supplies.",
},{"https://www.wowhead.com/quest=46701/hammer-of-forgotten-heroes"})

for _, area in ipairs({{630,"Northern Azsuna woodland north of Nar'thalas Academy"},{641,"Val'sharah woodland"},
    {680,"Suramar woodland and Felsoul Hold circuit"},{650,"Highmountain woodland"},{646,"The Weeping Terrace",0.4402,0.1690}}) do
    Add(251767,area[1],area[2],"Scout axe-marked housing trees and harvest Fel-Touched Lumber.",{
        "Complete Lumber For You and activate the Harvesting Hatchet on this character. Enable lumber tracking.",
        "The lumber binds to Warband. These are reported harvesting areas; trees are not guaranteed at an exact point.",
    },{URL(251767),"https://www.wowhead.com/guide/player-housing/crafting-decor-items"},area[3],area[4],"housing-lumber")
end

-- Existing vendor ingredients are audited but no new vendor-only catalog rows
-- are added. Keep the exact seller/faction requirement visible in their maps.
for _, id in ipairs({133588,133589,133590,133591,133592,133593}) do
    items[id].spots = {}
    for _, vendor in ipairs({{"Bradford Duncan in A Hero's Welcome - Alliance",0.408,0.652,93545},{"Misensi in The Filthy Animal - Horde",0.633,0.330,93537}}) do
        Add(id,627,vendor[1],"Buy " .. items[id].itemName .. " from the cooking supplier in your faction's Legion Dalaran inn.",{
            "Use Dalaran over the Broken Isles and your faction's inn. This is a vendor supply, not a mob or gathering drop.",
        },{URL(id),"https://www.wowhead.com/npc=" .. vendor[4]},vendor[2],vendor[3],"vendor-purchase")
    end
end

-- Currency trades supplement farms for existing items without adding vendor-only
-- records. Add after input snapshots so a vendor cannot become a mining pin.
local bloodTrade = {
    {124101,10},{124102,10},{124103,10},{124104,10},{124105,3},
    {123918,10},{123919,5},{124113,10},{124115,10},{124438,20},{124439,20},
    {124437,10},{124440,10},{124441,3},{124107,10},{124108,10},{124109,10},
    {124110,10},{124111,10},{124112,10},{124117,10},{124118,10},{124119,10},{124120,10},{124121,10},
}
for _, trade in ipairs(bloodTrade) do
    Add(trade[1],627,"Illnea Bloodthorn outside Tanks for Everything","Exchange one Blood of Sargeras with Illnea Bloodthorn for " .. trade[2] .. " " .. items[trade[1]].itemName .. ".",{
        "Use the Blood Trader outside the blacksmith/mining shop in Broken Isles Dalaran. Blood is soulbound and is also needed by Legion recipes.",
    },{"https://www.wowhead.com/npc=115264/illnea-bloodthorn"},0.446,0.324,"currency-trade")
end
for _, id in ipairs({151564,151565,151566,151567}) do
    Add(id,830,"Maras aboard the Vindicaar - material exchange","Board the Argus Vindicaar and exchange one Primal Sargerite with Maras for ten " .. items[id].itemName .. ".",{
        "Maras is on the lower deck by the profession trainers. This opens the access zone; take the ship's teleporter rather than searching for an outdoor vendor.",
    },{"https://www.wowhead.com/npc=129674/maras"})
end

for id in pairs(base) do
    local count, navigation, pins = 0, 0, 0
    for _, spot in ipairs(items[id].spots) do
        if id == 124444 then
            spot.farmAction = "When the Infernal Brimstone world quest is active, kill and mine its Brimstone Destroyer; Legion Mining 25 is required."
        end
        spot.sourceUrls = Merge(spot.sourceUrls or {},{URL(id)})
        if #spot.tips == 0 then spot.tips = {"Follow the named source and acquisition action; availability depends on the current character and zone."} end
        count, navigation, pins = count + 1, navigation + (spot.mapOnly and 1 or 0), pins + #(spot.coords or {})
    end
    audit.items[id] = {mapOptionCount = count, navigationCount = navigation, pinCount = pins}
end
NS.LegionBaseMaterialMapAudit = audit
