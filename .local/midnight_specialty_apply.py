import sys
sys.path.insert(0,'.local')
from midnight_specialty_research import *

recipes=json.loads((T/'selected-recipes.json').read_text(encoding='utf-8'))
raw=json.loads((T/'selected-specialties.json').read_text(encoding='utf-8'))
vendor=set(json.loads((T/'excluded-vendor.json').read_text()))
D=json.loads((T/'discovery.json').read_text())
def lua(v):
    if isinstance(v,bool):return 'true' if v else 'false'
    if isinstance(v,(int,float)):return str(v)
    if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
    if isinstance(v,list):return '{ '+', '.join(lua(x) for x in v)+' }'
    if isinstance(v,dict):return '{ '+', '.join(k+' = '+lua(x) for k,x in v.items() if x is not None)+' }'
    raise TypeError(v)

rows=[]
for recipe in sorted(recipes,key=lambda r:(r['profession'],r['name'],r['itemID'])):
    notes=[]
    for field in ['cooldownDescription','chargesDescription']:
        if recipe.get(field):notes.append(recipe[field])
    if recipe.get('qualityRank'):notes.append('quality '+str(recipe['qualityRank'])+' output; skill and chosen reagent quality determine achieved rank; listed inputs use baseline item references')
    if recipe.get('variableOutput'):notes.append('baseline batch only; bonus output is chance-based')
    if recipe['omittedVendorReagents']:notes.append('required purchased supplies omitted: '+', '.join(x['name']+' x'+str(x['quantity']) for x in recipe['omittedVendorReagents']))
    if recipe.get('requiredReagentSlots'):notes.append('required Competitor heraldry slot uses tradeable Galactic Combatant\'s Heraldry as the Season 1 baseline; other accepted seasonal heraldry differ')
    bound_inputs=[x for x in recipe['components'] if bound(x['itemID'])]
    if bound_inputs:notes.append('bound prerequisites, not AH products: '+', '.join(cached('item',x['itemID'])['name']+' x'+str(x['quantity']) for x in bound_inputs))
    if recipe['name'].startswith('Enchant '):notes.append('apply the enchant to Enchanting Vellum to sell the scroll; purchased vellum is omitted')
    assembly=recipe['name'].startswith('Darkmoon Deck:') or recipe['profession']=='fishing' and 'line' in recipe['name'].lower()
    if recipe['name'].startswith('Darkmoon Deck:'):notes.append('combine the matching Ace through Eight; individual cards are chance-based loot or crafting outcomes')
    source_type='item-use' if assembly else 'vendor' if 'Vendor:' in recipe['source'] else 'drop' if 'Drop:' in recipe['source'] else 'fishing' if 'Fishing:' in recipe['source'] else 'discovery' if 'Discovery:' in recipe['source'] else 'specialization' if 'Specialization:' in recipe['source'] else 'profession'
    row=dict(itemID=recipe['itemID'],itemName=recipe['name'],expansion='midnight',professions=[recipe['profession']],tag='Housing Decor' if recipe['housing'] else 'Elemental' if recipe['itemID'] in [236949,236950,236951,236952] else 'Darkmoon Deck' if recipe['name'].startswith('Darkmoon Deck:') else 'Crafted '+recipe['profession'].capitalize(),isRoute=False,auctionable=not recipe['bound'],outputQuantity=recipe['outputQuantity'],recipeSpellID=recipe['spellID'],recipeSource=source_type,recipeSourceLabel='; '.join([recipe['source']]+notes),components=recipe['components'])
    if recipe.get('qualityRank'):row['qualityRank']=recipe['qualityRank']
    rows.append(row)
for record in raw:
    row=dict(itemID=record['itemID'],itemName=record['itemName'],expansion='midnight',professions=record['professions'],tag=record['category'],isRoute=False,auctionable=record['auctionable'])
    for field in ['qualityRank','randomOutput','supportOnly']:
        if record.get(field) is not None:row[field]=record[field]
    rows.append(row)
assert len({r['itemID'] for r in rows})==len(rows)
by_id={r['itemID']:r for r in rows}
path=R/'Data/FarmingItems.lua'
before=(T/'before-Data__FarmingItems.lua').read_bytes()
assert path.read_bytes()==before,'Catalog changed during research; inspect before applying.'
text=before.decode('utf-8').replace('\r\n','\n');existing=set();lines=[]
for line in text.splitlines():
    match=re.search(r'itemID = (\d+), (?:itemName = "[^"]*", )?expansion = "([^"]+)"',line)
    if match:
        item_id=int(match[1]);existing.add(item_id)
        if match[2]=='midnight':
            if item_id in vendor:continue
            if item_id in by_id:line='        '+lua(by_id[item_id])+','
            elif 'tag = "Herb"' not in line and 'tag = "Ore"' not in line:
                raise AssertionError(('Unresearched existing Midnight material',item_id))
    lines.append(line)
text='\n'.join(lines)+'\n'
text=re.sub(r'dataVersion = (\d+),',lambda m:'dataVersion = '+str(int(m[1])+1)+',',text,count=1)
text=text.replace('New recipe chains show farmable inputs and omit vendor-sourced reagents.','New recipe chains show farmable inputs and omit vendor-sourced reagents. Midnight specialty materials, 783 verified compositions and 76 saleable housing crafts were checked on 2026-10-20; client spell effects verify output quantities, vendor-only supplies are excluded, and bound prerequisites are labeled.',1)
new=[r for r in rows if r['itemID'] not in existing]
assert text.endswith('    },\n}\n')
text=text[:-len('    },\n}\n')]+'        -- Midnight specialty materials, verified profession compositions, and housing crafts.\n'+''.join('        '+lua(r)+',\n' for r in new)+'    },\n}\n'
path.write_text(text,encoding='utf-8',newline='\n')
base=R/'Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight'
parts=['''local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local Items = NS.MaterialFarmingSpots.items

-- Evidence and exclusions: docs/research/midnight-specialty-2026-10-20.*.
-- Markers identify sourced search areas, never guaranteed drops or connected routes.
local RECORDS = {
''']
for record in raw:parts.append('    '+lua(record)+',\n')
parts.append('''}

local mapIDs = { ["Eversong Woods"] = 2395, ["Zul'Aman"] = 2437, Harandar = 2413, Voidstorm = 2405 }
local function CopySpot(spot)
    local copy = {}
    for key, value in pairs(spot) do copy[key] = value end
    copy.isRoute = false
    copy.mapID = copy.mapID or mapIDs[copy.mapName]
    return copy
end

for _, record in ipairs(RECORDS) do
    local previous = Items[record.itemID]
    local source = record.reuseFrom and Items[record.reuseFrom]
        or (record.preserveExistingSpots and previous)
    for _, spot in ipairs(source and source.spots or {}) do
        record.spots[#record.spots + 1] = CopySpot(spot)
    end
    for index, spot in ipairs(record.spots) do
        spot = CopySpot(spot)
        spot.tips = record.tips
        spot.sourceUrls = record.sourceUrls
        spot.source = "Published search area or documented lure placement; not independently tested in game"
        spot.inGameTested = false
        record.spots[index] = spot
    end
end
for _, record in ipairs(RECORDS) do Register(record) end
''')
(base/'Miscellaneous.lua').write_text(''.join(parts),encoding='utf-8',newline='\n')
(base/'Crafting.lua').write_text('''local _, NS = ...

NS.RegisterMaterialCraftingRecords("midnight")
for _, recipe in ipairs((NS.FarmingItems and NS.FarmingItems.items) or {}) do
    if recipe.expansion == "midnight" and recipe.recipeSpellID and recipe.components then
        local item = NS.MaterialFarmingSpots.items[recipe.itemID]
        if item then
            item.qualityRank = recipe.qualityRank
            item.sourceUrls[#item.sourceUrls + 1] = "https://wago.tools/db2/SpellEffect?filter[SpellID]=" .. recipe.recipeSpellID
        end
    end
end
''',encoding='utf-8',newline='\n')
housing=(R/'Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Housing.lua').read_text(encoding='utf-8')
housing=housing.replace('WarWithinHousing','MidnightHousing').replace('"warWithin"','"midnight"').replace('Dornic Fir Lumber','Thalassian Lumber')
housing=housing.replace('other bound intermediates are labeled as support inputs, not Auction House products.','Stabilized Derivate is bound Alchemy support. Neither is an Auction House product.')
(base/'Housing.lua').write_text(housing,encoding='utf-8',newline='\n')
for path in [R/'Data/General-Gold-Tracker_Materials/General-Gold-Tracker_Materials.toc',R/'tests/data/farming_data_spec.lua']:
    text=path.read_text(encoding='utf-8');anchor='    "Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Engineering.lua",' if path.suffix=='.lua' else 'MaterialFarmingSpots/Midnight/Engineering.lua'
    assert text.count(anchor)==1
    extra='\n'.join('    "Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/'+name+'.lua",' if path.suffix=='.lua' else 'MaterialFarmingSpots/Midnight/'+name+'.lua' for name in ['Miscellaneous','Crafting','Housing'])
    path.write_text(text.replace(anchor,anchor+'\n'+extra),encoding='utf-8',newline='\n')
path=R/'Data/General-Gold-Tracker_Materials/MaterialFarmingSpots.lua'
text=re.sub(r'dataVersion = (\d+),',lambda m:'dataVersion = '+str(int(m[1])+1)+',',path.read_text(encoding='utf-8'),count=1)
path.write_text(text,encoding='utf-8',newline='\n')
counts=dict(newEntries=len(new),newSaleable=sum(r['auctionable'] for r in new),boundSupport=sum(not r['auctionable'] for r in new),compositions=len(recipes),housingRecipes=sum(r['housing'] for r in recipes),specialties=len(raw),updatedExisting=len(rows)-len(new),byProfession=dict(Counter(r['profession'] for r in recipes)),vendorExclusions=sorted(vendor))
save('all-research-rows.json',rows);save('audit-counts.json',counts)
report=dict(researchedAt='2026-10-20',expansion='midnight',counts=counts,sources=json.loads((T/'sources.json').read_text()),compositions=recipes,specialties=raw,excludedVendorItems=[dict(itemID=i,name=cached('item',i).get('name')) for i in sorted(vendor)],omittedOutputs=[dict(itemID=i,name=cached('item',i).get('name'),bound=bound(i),future=i in D['futureIDs'],missingTooltip=not cached('item',i).get('name')) for i in D['housingIDs'] if i not in {r['itemID'] for r in recipes}],limitations=['Static source/client checks; no in-game test or auction sale is proven.','No new raw ore/herb products or vendor-only supplies. Existing raw ore/herb references remain legitimate craft inputs.','Exact baseline batches only; random milling, recycling, prospecting and fish processing have no invented conversion ratios.','No confirmed auctionable Midnight clam/container farm was added. Recipe bottle is Warband-bound; individual saleable recipe contents are cataloged.','Some Wowhead HTML item pages returned HTTP 403; tooltip API and client tables provided the recipe evidence.'])
(R/'docs/research/midnight-specialty-2026-10-20.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(counts))
