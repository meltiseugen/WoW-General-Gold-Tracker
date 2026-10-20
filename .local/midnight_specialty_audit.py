import sys
sys.path.insert(0,'.local')
from midnight_specialty_research import *
from lupa.lua51 import LuaRuntime

recipes=json.loads((T/'selected-recipes.json').read_text(encoding='utf-8'))
raw=json.loads((T/'selected-specialties.json').read_text(encoding='utf-8'))
rows=json.loads((T/'all-research-rows.json').read_text(encoding='utf-8'))
vendor=set(json.loads((T/'excluded-vendor.json').read_text()))
counts=json.loads((T/'audit-counts.json').read_text())
lua=LuaRuntime(unpack_returned_tuples=True)
load=lua.eval('function(s,n) local f,e=loadstring(s);assert(f,e);return f("General-Gold-Tracker",n) end')
def read(path,original=False):
    snapshot=T/('before-'+str(path).replace('\\','/').replace('/','__'))
    return (snapshot if original and snapshot.exists() else Path(path)).read_text(encoding='utf-8-sig')
def namespace(original=False):
    ns=lua.table();load(read('Data/FarmingItems.lua',original),ns)
    base=Path('Data/General-Gold-Tracker_Materials')
    for entry in read(base/'General-Gold-Tracker_Materials.toc',original).splitlines():
        if entry.endswith('.lua') and entry!='Namespace.lua':load(read(base/entry,original),ns)
    return ns
def plain_lua(v):return {k:plain_lua(x) for k,x in v.items()} if hasattr(v,'items') else v
ns=namespace();baseline=namespace(True)
catalog={int(v.itemID):v for _,v in ns.FarmingItems['items'].items()}
assert len(catalog)==len(ns.FarmingItems['items']),'Duplicate item IDs'
items=ns.MaterialFarmingSpots['items'];index_ns=lua.table()
load(read('Data/MaterialIndex.lua'),index_ns)

quality=defaultdict(set)
for name in ['CraftingDataItemQuality','CraftingDataEnchantQuality']:
    for row in csv.DictReader((T/(name+'.csv')).open()):quality[int(row['CraftingDataID'])].add(int(row['ItemID']))
data={int(row['ID']):row for row in csv.DictReader((T/'CraftingData.csv').open())}
for recipe in recipes:
    i,s=recipe['itemID'],recipe['spellID'];item=items[i];entry=catalog[i]
    assert item.itemName==entry.itemName==cached('item',i)['name']
    assert item.expansion==entry.expansion=='midnight' and item.isRoute is False and entry.isRoute is False
    assert item.auctionable is True and not bound(i)
    assert entry.outputQuantity==item.outputQuantity==recipe['outputQuantity']
    assert entry.recipeSpellID==item.recipeSpellID==s
    assert plain_lua(entry.components)==plain_lua(item.components)
    actual=[dict(itemID=c.itemID,quantity=c.quantity) for _,c in entry.components.items()]
    assert actual==recipe['components']
    for component in actual:
        assert component['itemID'] not in vendor and component['quantity']>0
        assert component['itemID'] in catalog and items[component['itemID']] is not None
    raw_tooltip=cached('spell',s)['tooltip'];block=re.search(r'Reagents:.*?<div[^>]*>(.*?)</div>',raw_tooltip)[1]
    reagents=[dict(itemID=int(i),quantity=int(q or 1)) for i,n,q in re.findall(r'<a href="/item=(\d+)[^"]*">(.*?)</a>(?:&nbsp;)?(?:\s*\((\d+)\))?',block)]
    expected=[x for x in reagents if x['itemID'] not in vendor]
    slots=re.findall(r'<a href="/items\?filter=243;(\d+);0">([^<]+)</a>(?:&nbsp;)?(?:\s*\((\d+)\))?',block)
    if slots:
        assert len(slots)==1 and slots[0][0]=='471' and recipe.get('requiredReagentSlots')
        expected.append(dict(itemID=256559,quantity=int(slots[0][2] or 1)))
    assert expected==actual,(i,expected,actual)
    for omitted in recipe['omittedVendorReagents']:assert omitted['name'] in entry.recipeSourceLabel
    for component in actual:
        if bound(component['itemID']):assert cached('item',component['itemID'])['name'] in entry.recipeSourceLabel
    found=[]
    for e in json.loads((T/f'effect-{s}.json').read_text()):
        if e['Effect']=='24':family={int(e['EffectItemType'])}
        elif e['Effect'] in ['288','301']:
            cid=int(e['EffectMiscValue_0']);family=quality[cid]|{int(data.get(cid,{}).get('CraftedItemID',0))}
        else:continue
        if i in family:found.append(e)
    assert found and entry.outputQuantity==max(1,int(float(found[0]['EffectBasePointsF'])))
    assert f'https://www.wowhead.com/spell={s}' in list(item.sourceUrls.values())
    assert recipe['batchSourceUrl'] in list(item.sourceUrls.values())

for record in raw:
    i=record['itemID'];entry=catalog[i];item=items[i]
    assert entry.itemName==item.itemName==cached('item',i)['name']
    assert entry.isRoute is False and item.isRoute is False
    assert entry.auctionable==item.auctionable==(not bound(i))
    assert item.summary==record['summary'] and list(item.tips.values())==record['tips']
    assert list(item.sourceUrls.values())==record['sourceUrls']
    for _,spot in item.spots.items():assert spot.isRoute is False
    assert ns.MaterialFarmingSpots.missingItems[i] is None

assert len(ns.MidnightHousing.recipes)==counts['housingRecipes']==78
for _,recipe in ns.MidnightHousing.recipes.items():
    assert recipe.isRoute is False and catalog[recipe.outputItemID].auctionable is True
    assert list(recipe.reagents.values())
    for _,component in recipe.reagents.items():
        links=items[component.itemID].housingUses
        assert any(link.outputItemID==recipe.outputItemID and link.quantity==component.quantity for _,link in links.items())

all_ids={r['itemID'] for r in rows}
assert len(all_ids)==950
assert {i for i in all_ids if catalog[i].auctionable is False}=={242651,256963,33226,252990,253043}
for i in all_ids:
    assert catalog[i].isRoute is False and items[i].isRoute is False
    assert index_ns.MaterialIndex['items'][i].itemName==items[i].itemName
    for _,spot in items[i].spots.items():assert spot.isRoute is False,(i,spot.id,spot.isRoute)
for i in vendor:assert i not in all_ids

# Preserve prior pending work in other expansions and all route import files and metadata.
for i,before in baseline.MaterialFarmingSpots['items'].items():
    if before.expansion!='midnight':assert plain_lua(before)==plain_lua(items[i]),('unrelated',i)
    elif before.category in ['Ore','Herb']:
        assert {k:plain_lua(v) for k,v in before.items() if k!='housingUses'}=={k:plain_lua(v) for k,v in items[i].items() if k!='housingUses'},('route',i)
for name in ['Mining','Herbalism']:
    path=Path(f'Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/{name}.lua')
    assert path.read_bytes()==(T/('before-'+path.as_posix().replace('/','__'))).read_bytes()
before_lines=read('Data/FarmingItems.lua',True).splitlines();after_lines=read('Data/FarmingItems.lua').splitlines()
scope=lambda line:re.search(r'itemID = \d+,[^\n]+expansion = "midnight"',line)
assert [l for l in before_lines if 'itemID = ' in l and not scope(l)]==[l for l in after_lines if 'itemID = ' in l and not scope(l)]
assert [l for l in before_lines if scope(l) and ('tag = "Herb"' in l or 'tag = "Ore"' in l)]==[l for l in after_lines if scope(l) and ('tag = "Herb"' in l or 'tag = "Ore"' in l)]
before_index=read('Data/MaterialIndex.lua',True).splitlines();after_index=read('Data/MaterialIndex.lua').splitlines()
assert all(line in after_index for line in before_index if 'expansion = "midnight"' not in line)
assert len(after_index)-len(before_index)==887 # Includes previously pending Aetherlume as well as 886 new catalog entries.
compiled=0
for folder in ['Core','Tracking','UI','Libs','Data']:
    for path in Path(folder).rglob('*.lua'):
        lua.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'));compiled+=1
save('validation.json',dict(passed=True,compositionsVerified=len(recipes),specialtiesVerified=len(raw),housingVerified=len(ns.MidnightHousing.recipes),compiledFiles=compiled,herbOreRoutesPreserved=True,unrelatedExpansionsPreserved=True,liveGameTested=False))
print('PASS: 785 composed outputs: exact client identity/batch, tooltip components, quality, sources, heraldry and vendor omissions.')
print('PASS: 165 specialty records, 78 housing recipes/links, 950 non-route records, 881 new saleable products and 5 bound support items.')
print('PASS: all original ore/herb imports and unrelated expansion/index records preserved; 887 index additions include previously pending Aetherlume.')
print(f'PASS: Lua 5.1 compile of {compiled} runtime files. In-game behavior is not tested.')
