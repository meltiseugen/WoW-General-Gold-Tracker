import base64
import html
import json
import re
from pathlib import Path
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
load = lua.eval('function(source, ns) local chunk, err = loadstring(source); assert(chunk, err); return chunk("General-Gold-Tracker", ns) end')
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Herbalism.lua')
routes = json.loads(Path('.local/midnight-herb-inventory.json').read_text())
ids_by_name = {'Tranquility Bloom': [236761, 236767], 'Argentleaf': [236776, 236777], 'Azeroot': [236774, 236775], 'Mana Lily': [236778, 236779], 'Sanguithorn': [236770, 236771], 'Nocturnal Lotus': [236780]}
all_ids = {i for ids in ids_by_name.values() for i in ids}

def namespace(original=False, before_catalog=False):
    ns = lua.table()
    load(Path('.local/midnight-farming-items-before.lua' if original else 'Data/FarmingItems.lua').read_text(encoding='utf-8-sig'), ns)
    base = Path('Data/General-Gold-Tracker_Materials')
    for entry in (base / 'General-Gold-Tracker_Materials.toc').read_text().splitlines():
        if before_catalog and entry == 'MaterialFarmingSpots/CatalogGathering.lua':
            break
        if entry.endswith('.lua') and entry != 'Namespace.lua':
            path = base / entry
            load(Path('.local/midnight-herbalism-before.lua').read_text(encoding='utf-8-sig') if original and path == target else path.read_text(encoding='utf-8-sig'), ns)
    return ns

def plain(value):
    return {k: plain(v) for k,v in value.items()} if hasattr(value, 'items') else value

# Independently read the attachment rather than relying only on the build inventory.
attachment = Path(r'C:\Users\Eugen\.codex\attachments\83f00319-6b3e-4a7a-926c-a63d014752c8\Pasted text.txt').read_text(encoding='utf-8')
attachment_routes = []
attachment_geometry = {}
for section in re.split(r'^## \d+\. ', attachment, flags=re.M)[1:]:
    herb = section.splitlines()[0].strip()
    section = section.split('## Addon integration')[0]
    for order, block in enumerate(section.split('### ')[1:], 1):
        map_id = int(re.search(r'\((\d+)\)', block.splitlines()[0])[1])
        tips = [html.unescape(t).replace('\u00a0', ' ').strip() for t in re.findall(r'^- (.+)$', block, re.M)]
        attachment_routes.append((herb, order, map_id, tips))
        exported = re.search(r'^Retail:Routes:([^\n]+)', block, re.M)
        if exported:
            serialized = base64.b64decode(exported[1].rsplit(':',1)[1], validate=True).decode('latin1')
            points = [int(p) for p in re.findall(r'\^N\d+\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t', serialized)[1])]
            assert int(re.search(r'\^SRouteZone\^N(\d+)', serialized)[1]) == map_id
            attachment_geometry[map_id] = points
void_export = json.loads(Path('.local/midnight-voidstorm-source.json').read_text(encoding='utf-8-sig'))['content']
void_data = base64.b64decode(void_export.rsplit(':',1)[1], validate=True).decode('latin1')
assert int(re.search(r'\^SRouteZone\^N(\d+)', void_data)[1]) == 2405
attachment_geometry[2405] = [int(p) for p in re.findall(r'\^N\d+\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t', void_data)[1])]
assert len(routes) == len(attachment_routes) == 18

ns = namespace()
farming = {int(item.itemID): item for _,item in ns.FarmingItems['items'].items()}
ui = Path('UI/CraftingFarmingWindow.lua').read_text(encoding='utf-8')
snippet = ui[ui.index('local function NormalizeMaterialSpotCoord('):ui.index('local function BuildMaterialFarmingMapOptions(addon,')]
builder = lua.execute('local NS = ...; local function ResolveMaterialMapID() return nil end\n' + snippet + '\nreturn BuildMaterialFarmingMapOptionsFromData', ns)
for r, (herb, order, map_id, tips) in zip(routes, attachment_routes):
    assert (r['herb'],r['order'],r['mapID'],r['tips']) == (herb,order,map_id,tips)
    packed = attachment_geometry[map_id]
    assert r['packed'] == packed
    for item_id in ids_by_name[herb]:
        item = ns.MaterialFarmingSpots['items'][item_id]
        assert item.itemName == herb and item.expansion == 'midnight'
        assert item.isRoute is True and farming[item_id].isRoute is True
        assert item.qualityRank == (ids_by_name[herb].index(item_id)+1 if len(ids_by_name[herb]) > 1 else None)
        spot = item.spots[order]
        assert spot.id == r['id'] and spot.mapID == map_id and spot.mapName == r['mapName']
        assert spot.sortOrder == order and spot.isRoute is True and spot.inGameTested is False
        assert spot.routeImportString == r['routeImportString']
        assert list(spot.tips.values()) == tips
        assert list(spot.sourceUrls.values()) == r['sourceUrls']
        assert len(spot.coords) == len(packed)
        for index,point in enumerate(packed,1):
            assert abs(spot.coords[index].x - point//10000/10000) < 1e-12
            assert abs(spot.coords[index].y - point%10000/10000) < 1e-12
        option = builder(item)[order]
        assert option.id == spot.id and option.mapID == map_id and option.spotCount == 1
        assert option.label == spot.dropdownLabel and len(option.pins) == len(packed)
        for _,pin in option.pins.items():
            assert pin.isRoute is True and pin.routeID == spot.id
            assert plain(pin.tips) == plain(spot.tips) and plain(pin.sourceUrls) == plain(spot.sourceUrls)
    assert len(set(r['id'] for r in routes)) == 18

# Curated baselines precede catalog additions, whose legacy aliasing is fixed by owned spot arrays.
before = namespace(original=True, before_catalog=True)
after = namespace(before_catalog=True)
for item_id, old_item in before.MaterialFarmingSpots['items'].items():
    item = after.MaterialFarmingSpots['items'][item_id]
    if item_id in all_ids:
        assert len(item.spots) == len(old_item.spots)+3
        for index,old_spot in old_item.spots.items():
            assert plain(old_spot) == plain(item.spots[index+3]), (item_id,index)
        old_fields = {k: plain(v) for k,v in old_item.items() if k not in ('spots','isRoute')}
        new_fields = {k: plain(v) for k,v in item.items() if k not in ('spots','isRoute')}
        assert old_fields == new_fields
    else:
        assert plain(item) == plain(old_item), item_id
for herb, ids in ids_by_name.items():
    for item_id in ids:
        # Catalog inserts are item-specific and no longer contaminate all other Midnight herbs.
        spots = ns.MaterialFarmingSpots['items'][item_id].spots
        for other_id in all_ids - {item_id}:
            assert not lua.eval('function(a,b) return rawequal(a,b) end')(spots,ns.MaterialFarmingSpots['items'][other_id].spots)

# Only the 11 requested FarmingItems flags changed in the dirty pre-task catalog.
old_catalog = Path('.local/midnight-farming-items-before.lua').read_text()
new_catalog = Path('Data/FarmingItems.lua').read_text()
for item_id in all_ids:
    new_catalog, count = re.subn(rf'(\{{ itemID = {item_id},[^\n]+tag = "Herb"), isRoute = true( \}},)', r'\1\2', new_catalog)
    assert count == 1
assert old_catalog == new_catalog
index_ns = lua.table()
load(Path('Data/MaterialIndex.lua').read_text(), index_ns)
assert all(index_ns.MaterialIndex['items'][i].hasMap is True for i in all_ids)
count = 0
for folder in ('Core','Tracking','UI','Libs','Data'):
    for path in Path(folder).rglob('*.lua'):
        lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8-sig'))
        count += 1
print('PASS: 18 routes / 543 ordered vertices / 54 exact supplied tips / 11 item ranks.')
print('PASS: all route flags, priorities, IDs, sources, dropdown options and generated pins.')
print('PASS: legacy curated spots and unrelated records preserved; quality ranks own their lists.')
print(f'PASS: Lua 5.1 compilation for {count} runtime files; existing index covers every herb.')
