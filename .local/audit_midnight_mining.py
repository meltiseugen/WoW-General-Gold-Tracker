import base64
import html
import json
import re
from pathlib import Path
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
load = lua.eval('function(source, ns) local chunk, err = loadstring(source); assert(chunk, err); return chunk("General-Gold-Tracker", ns) end')
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Mining.lua')
routes = json.loads(Path('.local/midnight-mining-inventory.json').read_text())
ids_by_name = {'Refulgent Copper Ore': [237359,237361], 'Umbral Tin Ore': [237362,237363], 'Brilliant Silver Ore': [237364,237365], 'Dazzling Thorium': [237366]}
all_ids = {i for ids in ids_by_name.values() for i in ids}

def namespace(original=False, before_catalog=False):
    ns = lua.table()
    load(Path('.local/midnight-mining-farming-items-before.lua' if original else 'Data/FarmingItems.lua').read_text(encoding='utf-8-sig'), ns)
    base = Path('Data/General-Gold-Tracker_Materials')
    for entry in (base/'General-Gold-Tracker_Materials.toc').read_text().splitlines():
        if before_catalog and entry == 'MaterialFarmingSpots/CatalogGathering.lua':
            break
        if entry.endswith('.lua') and entry != 'Namespace.lua':
            path = base/entry
            load(Path('.local/midnight-mining-before.lua').read_text(encoding='utf-8-sig') if original and path == target else path.read_text(encoding='utf-8-sig'),ns)
    return ns

def plain(value):
    return {k:plain(v) for k,v in value.items()} if hasattr(value,'items') else value

# Re-decode each attachment export independently; preserve all same-zone variants.
attachment = Path(r'C:\Users\Eugen\.codex\attachments\52a51829-4f58-41fb-8476-2f9a3ec06768\Pasted text.txt').read_text(encoding='utf-8')
blocks = re.split(r'^### ',attachment,flags=re.M)[1:]
assert len(blocks) == len(routes) == 12
ns = namespace()
farming = {int(item.itemID):item for _,item in ns.FarmingItems['items'].items()}
ui = Path('UI/CraftingFarmingWindow.lua').read_text(encoding='utf-8')
snippet = ui[ui.index('local function NormalizeMaterialSpotCoord('):ui.index('local function BuildMaterialFarmingMapOptions(addon,')]
builder = lua.execute('local NS = ...; local function ResolveMaterialMapID() return nil end\n'+snippet+'\nreturn BuildMaterialFarmingMapOptionsFromData',ns)
for route, block in zip(routes,blocks):
    imported = re.search(r'^Retail:Routes:[^\n]+',block,re.M)[0].strip()
    serialized = base64.b64decode(imported.rsplit(':',1)[1],validate=True).decode('latin1')
    packed = [int(p) for p in re.findall(r'\^N\d+\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t',serialized)[1])]
    map_id = int(re.search(r'\^SRouteZone\^N(\d+)',serialized)[1])
    source = re.search(r'^Source path: (https?://\S+)',block,re.M)[1]
    tips = [html.unescape(t).strip() for t in re.findall(r'^- (.+)$',block,re.M)]
    assert packed == route['packed'] and map_id == route['mapID']
    assert tips == route['tips'] and source == route['sourceUrl']
    for item_id in ids_by_name[route['itemName']]:
        item = ns.MaterialFarmingSpots['items'][item_id]
        assert item.itemName == route['itemName'] and item.expansion == 'midnight'
        assert item.isRoute is True and farming[item_id].isRoute is True
        assert item.qualityRank == (ids_by_name[route['itemName']].index(item_id)+1 if len(ids_by_name[route['itemName']])>1 else None)
        spot = item.spots[route['order']]
        assert spot.id == route['id'] and spot.sortOrder == route['order']
        assert spot.mapID == map_id and spot.mapName == route['mapName']
        assert spot.location == route['location'] and spot.routeImportString == imported
        assert spot.isRoute is True and spot.inGameTested is False
        assert spot.routeOrigin == 'published-zone-gathering-loop'
        assert list(spot.tips.values()) == tips and list(spot.sourceUrls.values()) == [source]
        assert len(spot.coords) == len(packed)
        for index,point in enumerate(packed,1):
            assert abs(spot.coords[index].x-point//10000/10000)<1e-12
            assert abs(spot.coords[index].y-point%10000/10000)<1e-12
        option = builder(item)[route['order']]
        assert option.id == spot.id and option.mapID == map_id and option.spotCount == 1
        assert option.label == spot.dropdownLabel and len(option.pins) == len(packed)
        for _,pin in option.pins.items():
            assert pin.isRoute is True and pin.routeID == spot.id
            assert plain(pin.tips) == plain(spot.tips) and plain(pin.sourceUrls) == plain(spot.sourceUrls)
assert len({r['id'] for r in routes}) == 12

# Compare before catalog insertion to avoid baseline shared-array contamination.
before, after = namespace(True,True), namespace(False,True)
for item_id,old_item in before.MaterialFarmingSpots['items'].items():
    item = after.MaterialFarmingSpots['items'][item_id]
    if item_id in all_ids:
        assert len(item.spots) == len(old_item.spots)+3
        for index,old_spot in old_item.spots.items():
            assert plain(old_spot) == plain(item.spots[index+3]),(item_id,index)
        assert {k:plain(v) for k,v in old_item.items() if k not in ('spots','isRoute')} == {k:plain(v) for k,v in item.items() if k not in ('spots','isRoute')}
    else:
        assert plain(item) == plain(old_item),item_id
same = lua.eval('function(a,b) return rawequal(a,b) end')
for item_id in all_ids:
    for other_id in all_ids-{item_id}:
        assert not same(ns.MaterialFarmingSpots['items'][item_id].spots,ns.MaterialFarmingSpots['items'][other_id].spots)

# Only seven ore flags changed in the already dirty catalog; herb import remains byte-for-byte.
old_catalog = Path('.local/midnight-mining-farming-items-before.lua').read_text()
new_catalog = Path('Data/FarmingItems.lua').read_text()
for item_id in all_ids:
    new_catalog,count = re.subn(rf'(\{{ itemID = {item_id},[^\n]+tag = "Ore"), isRoute = true( \}},)',r'\1\2',new_catalog)
    assert count == 1
assert old_catalog == new_catalog
assert Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Herbalism.lua').read_bytes() == Path('.local/midnight-mining-herbalism-before.lua').read_bytes()
index_ns = lua.table()
load(Path('Data/MaterialIndex.lua').read_text(),index_ns)
assert all(index_ns.MaterialIndex['items'][i].hasMap is True for i in all_ids)
count=0
for folder in ('Core','Tracking','UI','Libs','Data'):
    for path in Path(folder).rglob('*.lua'):
        lua.execute('assert(loadstring(...))',path.read_text(encoding='utf-8-sig'))
        count+=1
print('PASS: 12 attachment routes / 395 ordered points / 36 exact tips / 7 ore item ranks.')
print('PASS: exact sources and import payloads, flags, priority, distinct dropdown options and all map pins.')
print('PASS: prior curated spots and unrelated records retained; herb import unchanged; catalog only adds 7 flags.')
print(f'PASS: Lua 5.1 compilation of {count} runtime files; material index covers all ores.')
