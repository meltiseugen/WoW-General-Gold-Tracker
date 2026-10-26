local _, NS = ...

-- Missing non-Composed Midnight maps only. Existing instance/gathering maps
-- remain intact. See docs/research/midnight-missing-map-audit-2026-10-23.md.
if NS.MidnightMissingMaterialMapAudit then return end
local items = NS.MaterialFarmingSpots.items
local audit = {researchedAt="2026-10-23",items={},missingItems={},repairedItems={}}
NS.MidnightMissingMaterialMapAudit = audit

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key,entry in pairs(value) do result[key] = Copy(entry) end
    return result
end
local function Merge(first,second)
    local result,seen = {},{}
    for _,list in ipairs({first or {},second or {}}) do
        for _,value in ipairs(list) do
            if not seen[value] then result[#result+1],seen[value] = value,true end
        end
    end
    return result
end
local maps = {
    [2393]="Silvermoon City",[2395]="Eversong Woods",[2437]="Zul'Aman",
    [2413]="Harandar",[2405]="Voidstorm",[2444]="Slayer's Rise",
    [2512]="The Coiled Isle",[2537]="Quel'Thalas",
}
local mapIDs = {}
for id,name in pairs(maps) do mapIDs[name] = id end

local function Prepare(id,sources,tips)
    local item = assert(items[id],"Missing Midnight material " .. id)
    assert(item.expansion == "midnight","Wrong expansion in Midnight map scope")
    assert(not item.components or #item.components == 0,"Composed item in Midnight map scope")
    assert(not item.spots or #item.spots == 0,"Would replace existing Midnight maps")
    item = Copy(item)
    items[id],item.spots,item.researchedAt = item,{},audit.researchedAt
    item.sourceUrls = Merge(item.sourceUrls,Merge({"https://www.wowhead.com/item=" .. id},sources))
    item.tips = Merge(tips,item.tips)
    item.isRoute = false
    audit.items[id],audit.missingItems[id] = true,true
    return item
end
local function AddPlace(item,mapID,location,action,kind,coords,role)
    local spot = {
        id="midnight-map-" .. item.itemID .. "-" .. (#item.spots+1),
        mapID=mapID,mapName=assert(maps[mapID]),location=location,
        routeType=kind,mapRole=role or "source-area",farmAction=action,
        coords=Copy(coords or {}),mapOnly=not coords or #coords == 0,
        isRoute=false,inGameTested=false,
        source="Published acquisition guidance; coordinates, when present, are reported access or fishing locations",
        sourceUrls=Copy(item.sourceUrls),tips=Copy(item.tips),
        density="Variable; no measured hourly yield",
        dropDifficulty="Source access, profession setup and reward eligibility apply; no fixed output or drop chance.",
    }
    item.spots[#item.spots+1] = spot
    return spot
end
local function AddInputs(item,inputs,kind,action)
    item.mapInputItemIDs = Copy(inputs)
    for _,id in ipairs(inputs) do
        local input = assert(items[id])
        for _,source in ipairs(input.spots or {}) do
            local spot = Copy(source)
            spot.id = "midnight-input-" .. item.itemID .. "-" .. id .. "-" .. source.id
            spot.mapID = tonumber(source.mapID) or mapIDs[source.mapName]
            assert(spot.mapID,"Unresolved Midnight input map: " .. tostring(source.mapName))
            spot.location = input.itemName .. " input - " .. (source.location or source.mapName)
            spot.inputItemID,spot.inputRouteID = id,source.id
            spot.routeType,spot.farmAction = kind,action(input.itemName)
            spot.isRoute,spot.inGameTested = false,false
            spot.sourceUrls,spot.tips = Merge(source.sourceUrls,item.sourceUrls),Merge(item.tips,source.tips)
            spot.density = "Input gathering; no measured yield of the selected output"
            spot.dropDifficulty = "Gather the input, then follow the processing steps. Target output and quality are not guaranteed by a map marker."
            item.spots[#item.spots+1] = spot
        end
    end
    assert(#item.spots > 0,"No Midnight input maps for " .. item.itemID)
end

for _,family in ipairs({
    {id=245803,input=236776}, -- Argentleaf
    {id=245807,input=236761}, -- Powder / Tranquility Bloom; Azeroot is not a milling input here.
    {id=245865,input=236770}, -- Sanguithorn
    {id=245867,input=236778}, -- Mana Lily
}) do
    local item = Prepare(family.id,{
        "https://www.method.gg/guides/midnight-inscription-profession-guide",
        "https://www.wowhead.com/spell=1269575/midnight-milling",
    },{"Gather the matching herb family, then use Midnight Milling on ten matching herbs. These maps locate herb inputs, not pigment drops. Processing results depend on your setup."})
    AddInputs(item,{family.input},"milling-input",function(name)
        return "Gather " .. name .. ", then use Midnight Milling on ten matching herbs for " .. item.itemName .. "."
    end)
end

local oreInputs = {237359,237362,237364}
for _,family in ipairs({
    {id=242606,inputs={237359,237362}}, -- Tenebrous Amethyst
    {id=242610,inputs={237362}}, -- Flawless Harandar Peridot
    {id=242611,inputs={237362}}, -- Flawless Tenebrous Amethyst
    {id=242613,inputs={237364}}, -- Flawless Sanguine Garnet
    {id=242788,inputs=oreInputs}, -- Dusk-Shrouded Stone
    {id=242608,inputs={237366}}, -- Eversong Diamond / Dazzling Thorium
}) do
    local item = Prepare(family.id,{
        "https://www.wowhead.com/spell=1231127/midnight-prospecting",
        "https://www.method.gg/guides/midnight-jewelcrafting-profession-guide",
    },{"Mine the listed ore inputs, then prospect five matching Midnight ores with Jewelcrafting. These are ore-input maps; a particular gem, quality or byproduct is not guaranteed."})
    if family.id == 242608 then
        item.tips = Merge({"Dazzling Thorium is a rare gathering bonus, not a dedicated deposit. Prospect it for a chance at Eversong Diamond; the relevant prospecting specialization can also unlock a small Diamond chance from other Midnight ores."},item.tips)
    end
    AddInputs(item,family.inputs,"prospecting-input",function(name)
        if family.id == 242608 then
            return "Mine eligible Midnight ore for bonus Dazzling Thorium, then prospect five matching ores for a chance at Eversong Diamond."
        end
        return "Mine " .. name .. ", then use Midnight Prospecting on five matching ores for a chance at " .. item.itemName .. "."
    end)
end
local dust = Prepare(242620,{
    "https://www.wowhead.com/spell=1231132/midnight-crushing",
    "https://www.wowhead.com/spell=1231127/midnight-prospecting",
},{"Midnight Crushing consumes three eligible Midnight gems AND one Dusk-Shrouded Stone. Prospect ore to obtain these inputs, then crush; Glimmering Gemdust is not a direct ore or prospecting drop."})
AddInputs(dust,oreInputs,"prospecting-crushing-input",function(name)
    return "Mine " .. name .. ", prospect it for gems and Dusk-Shrouded Stone, then crush three gems plus one Stone into Glimmering Gemdust."
end)

local recyclingSources = {
    "https://www.wowhead.com/spell=1229930/recycling",
    "https://www.wow-professions.com/midnight/engineering-guide",
}
for _,id in ipairs({243581,243582}) do
    local item = Prepare(id,recyclingSources,{
        "Engineering Recycling destroys five matching eligible crafted reagents. Powder Pigment is an Evercore input: gather Tranquility Bloom, mill it, then recycle the pigment. These are gathering inputs, not Evercore deposits.",
        "Recycling inputs determine the output family; input quality and profession setup affect achieved quality. No fixed conversion yield is assumed.",
    })
    AddInputs(item,{236761},"milling-recycling-input",function()
        return "Gather Tranquility Bloom, mill ten matching herbs into Powder Pigment, then recycle five matching pigments with Engineering for Evercore."
    end)
end
for _,id in ipairs({243578,243579}) do
    local item = Prepare(id,recyclingSources,{
        "Craft Soul Sprockets from Refulgent Copper Ore and Umbral Tin Ore, then recycle five matching Sprockets for Aetherlume. Crafting also requires purchased Malleable Wireframe; the ore maps are not the complete crafting cost.",
        "Imbued Bright Linen Bolt is another eligible Aetherlume input. This differs from basic Bright Linen Bolt, which produces Evercore. No fixed output rank or yield is assumed.",
    })
    AddInputs(item,{237359,237362},"crafting-recycling-input",function()
        return "Gather Refulgent Copper and Umbral Tin, craft Soul Sprockets (also requires purchased Malleable Wireframe), then recycle five matching Sprockets into Aetherlume."
    end)
end

local fishingGuide = "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools"
for _,id in ipairs({238489,238494,262650,262651,262792,262797}) do
    local item = Prepare(id,{fishingGuide}, {
        "Fish eligible Midnight waters for this incidental catch or fishing-line fragment. These are source-area alternatives, not fixed pool spawns or guaranteed catches.",
    })
    if id == 262650 or id == 262651 then
        item.tips = {"This is a consumable fishing lure, not a Cosmetic appearance. Unused lures can be sold; the item is Unique (20). It is an incidental fishing catch, without a guaranteed pool or catch rate."}
    elseif id == 238489 or id == 238494 then
        item.tips = {"This is a novelty catch, not a Cosmetic appearance or crafting material. Fish eligible Midnight waters; no fixed catch chance is assumed."}
    else
        item.sourceUrls = Merge(item.sourceUrls,{"https://www.wowhead.com/item=262793/stranded-bloomline"})
        item.tips = Merge({"The Shredded fragment is a base catch; combining fragments into higher fishing-line tiers is separate processing. Do not treat the map as a guaranteed line farm."},item.tips)
    end
    item.summary = "Incidental Midnight fishing catch; use the listed source areas without assuming a fixed pool or catch probability."
    for _,mapID in ipairs({2395,2437,2413,2512}) do
        AddPlace(item,mapID,"Eligible fishing waters","Fish eligible " .. maps[mapID] .. " waters for a chance at " .. item.itemName .. ".","fishing-source-area")
    end
end
local rock = Prepare(266102,{
    "https://www.wowhead.com/item=266102/ambiguous-rock",
    "https://www.wowhead.com/item=238490/ambiguous-rock",
},{"Fish the precursor Ambiguous Rock (238490), then wait for it to transform into the inspectable Ambiguous Rock (266102). Published reports describe a five-minute wait; no guaranteed catch or inspection outcome is assumed."})
rock.tips = {"Fish precursor Ambiguous Rock (238490), then wait for the inspectable rock (266102); reports describe five minutes. The map locates eligible Midnight fishing regions, not a direct catch of 266102. Inspecting it has random novelty outcomes. This item has no Cosmetic tooltip type."}
rock.summary = "Midnight fishing novelty from the fished-rock inspection/conversion chain."
rock.mapInputItemIDs = {238490}
AddPlace(rock,2537,"Midnight waters - precursor Ambiguous Rock fishing","Fish precursor Ambiguous Rock (238490), then wait for it to transform into the inspectable rock (266102).","fishing-rock-conversion-input")

-- Pool locations rotate. Keep pool-specific and unlock guidance without
-- inventing spawn pins or drawing a path through unknown pool positions.
local fishFamilies = {
    {id=274587,pool="open water near Tokka's Folly",pin={x=0.515,y=0.537,label="Spotted Killifish open-water report"}},
    {id=274589,pool="Bubbling Beryl pools",tip="Ula'tek Snakehead Lure improves targeting and enables a reported open-water alternative; it is not required for Bubbling Beryl catches."},
    {id=274591,pool="Torrential Gorgerswarm",tip="Use Coiled Stargorger Lure on an eligible Coiled Isle pool to create a Torrential Gorgerswarm. This is a converted pool, not a naturally spawning one. Buying the lure avoids needing its reputation-gated recipe."},
    {id=274594,pool="Willow Sea pools"},
    {id=279091,pool="Cursed Oddity pools"},
    {id=279094,pool="Cursed Oddity pools",tip="Eerie Lure open-water catches are also reported. Pool and catch conditions vary; no fixed rate is assumed."},
    {id=279105,pool="Vile Venom pools"},
    {id=274592,pool="Bubbling Beryl pools and reported open water"},
    {id=274590,pool="Bubbling Beryl pools"},
    {id=274588,pool="Bubbling Beryl or Willow Sea pools"},
    {id=274593,pool="eligible pools after the Blightswarmer unlock",tip="Reports require Venom Fishing: Shell of Yourself, followed by completing a Curse Surge for the fishing-enabling buff. Check the active buff and quest progression; no duration is assumed."},
    {id=279093,pool="Cursed Oddity pools"},
    {id=279100,pool="Vile Venom pools"},
    {id=279106,pool="Vile Venom pools"},
}
for _,family in ipairs(fishFamilies) do
    local item = Prepare(family.id,{
        "https://www.wowhead.com/achievement=63629/angler-of-the-coiled-isle",
        "https://www.wowhead.com/spell=1295421/venom-fishing",
    },{
        "Search The Coiled Isle for " .. family.pool .. ". These are published player-reported pool targets; pools rotate and the map does not guarantee a spawn.",
        "Unlock the relevant fishing progression before entering venom waters. Venom Fishing from Captain Tokka's questline and Cursed Land and Waters from Curse Surges are separate requirements; neither is assumed to unlock every catch.",
        family.tip or "Use Find Fish to locate the named pool type. Catch counts and skill estimates in historical reports are not guaranteed rates or hard requirements.",
    })
    AddPlace(item,2512,family.pool,"Fish " .. family.pool .. " on The Coiled Isle for " .. item.itemName .. "; follow its lure and unlock requirements in Tips.","targeted-fishing-source",family.pin and {family.pin})
    if family.pin then item.spots[1].confidence = "player-reported" end
    if family.id == 274591 then
        item.sourceUrls = Merge(item.sourceUrls,{"https://www.wowhead.com/item=241151/coiled-stargorger-lure"})
        item.spots[1].sourceUrls = Copy(item.sourceUrls)
        local access = AddPlace(item,2512,"Second Mate Sluggs - lure recipe access","Check Second Mate Sluggs for the Coiled Stargorger Lure recipe at Cursed Angler reputation, or buy the finished lure. This marker is recipe access, not a fishing pool.","fishing-recipe-access",{{x=0.516,y=0.498,label="Second Mate Sluggs - lure recipe access"}},"access")
        access.confidence = "player-reported"
    end
end

local fillet = Prepare(253403,{"https://www.wowhead.com/spell=1259655/thalassian-fillet"},{
    "Current Thalassian Fillet processing consumes ONE eligible Midnight fish. Older five-fish descriptions are stale. Cooking skill and fish rarity affect output; no fixed yield is assumed.",
})
AddInputs(fillet,{238371,238365},"cooking-fillet-input",function(name)
    return "Fish " .. name .. ", then use Midnight Cooking Thalassian Fillet on one fish; this destroys the fish."
end)

for _,id in ipairs({275695,275334,275338,275306,275308,275273,278331,275320,275684,278330,278333,275324,275326}) do
    local item = Prepare(id,{"https://www.wowhead.com/item=278329/thalassian-recipe-in-a-bottle",fishingGuide},{
        "Search Careless Cargo and Lost Treasures pools, fish Thalassian Recipe in a Bottle, then open it for a random recipe. The bottle is Warband-bound; these maps target the listed unused recipe output, not sale of the bottle.",
        "Coiled Isle recipes are also reported from eligible treasure pools in older Midnight zones. No profession requirement, daily cap, duplicate protection or recipe drop probability is assumed from conflicting comments.",
    })
    for _,mapID in ipairs({2395,2437,2413,2512}) do
        AddPlace(item,mapID,"Careless Cargo / Lost Treasures pool search","Fish Careless Cargo or Lost Treasures in " .. maps[mapID] .. ", then open Thalassian Recipe in a Bottle for a chance at " .. item.itemName .. ".","fishing-recipe-container-source")
    end
end

local heliotrope = Prepare(253307,{
    "https://warcraft.wiki.gg/wiki/Infused_Heliotrope",
    "https://www.wow-professions.com/midnight/npc/mirvedon",
},{"Earn eligible Midnight PvP reward containers or Honor, then check Mirvedon's Infused Heliotrope stock. The map shows the Silvermoon quartermaster hub; battleground and arena queues can be entered elsewhere. No current reward rate or fixed vendor price is assumed."})
AddPlace(heliotrope,2393,"Silvermoon PvP quartermaster hub","Earn eligible PvP rewards or check Mirvedon's Honor purchase alternative for Infused Heliotrope.","pvp-quartermaster-access")
local heraldry = Prepare(256559,{"https://warcraft.wiki.gg/wiki/Galactic_Combatant%27s_Heraldry"},{
    "Legacy Midnight Season 1 reagent: Galactic Combatant's Heraldry can no longer be earned from its original seasonal sources. The map provides historical Silvermoon quartermaster context. Check existing tradeable stock; current-season Heraldry is a different item.",
})
heraldry.summary = "Legacy Midnight Season 1 PvP reagent; original seasonal earning sources have ended."
heraldry.tips = {"Galactic Combatant's Heraldry can no longer be earned from its original Season 1 sources. The map is historical quartermaster context, not a current reward farm. Existing tradeable stock may remain."}
AddPlace(heraldry,2393,"Historical Season 1 quartermaster context","Historical source only: Galactic Combatant's Heraldry can no longer be earned from its original season; check existing tradeable stock.","legacy-season-source")

for _,id in ipairs({274777,274781}) do
    local item = Prepare(id,{
        "https://www.method.gg/guides/farming-routes-for-neutralized-venom-clot-and-cursebound-globes-in-wow-midnight",
        "https://www.wowhead.com/guide/midnight/professions/herbalism-overview-trainer-locations-treasures-tools",
    },{
        "Complete a Curse Surge on The Coiled Isle and use the Cursed Land and Waters window to search for the relevant modified nodes. Ordinary nodes elsewhere do not supply this reagent; no permanent node location is asserted.",
        "Venomous nodes must be cleansed; their draining bar can deal damage, then green puddles/orbs appear to collect for Neutralized Venom Clot. Venomous nodes cannot be Overloaded.",
        "Cursed ore/herbs supply Cursebound Globe and can be Overloaded. Other gathering professions have reported sources, but the selected map guidance specifically covers Herbalism and Mining.",
    })
    local action = id == 274777
        and "After a Curse Surge, gather Venomous nodes on The Coiled Isle, finish cleansing them and collect the green puddles/orbs for Neutralized Venom Clot."
        or "After a Curse Surge, gather Cursed ore or herbs on The Coiled Isle for Cursebound Globe; eligible Cursed nodes can be Overloaded."
    AddPlace(item,2512,"Cursed Land and Waters - modified-node search",action,"modified-node-source-area")
end
