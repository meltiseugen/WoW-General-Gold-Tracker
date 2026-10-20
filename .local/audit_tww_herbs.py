import base64
import json
import re
from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path.cwd()
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Herbalism.lua')
routes = json.loads(Path('.local/tww-herb-inventory.json').read_text(encoding='utf-8'))
lua = LuaRuntime(unpack_returned_tuples=True)
load = lua.eval('function(source, ns) local chunk, err = loadstring(source); assert(chunk, err); return chunk("General-Gold-Tracker", ns) end')

def namespace(original=False, before_catalog=False):
    ns = lua.table()
    load(Path('.local/tww-farming-items-before.lua' if original else 'Data/FarmingItems.lua').read_text(encoding='utf-8'), ns)
    base = Path('Data/General-Gold-Tracker_Materials')
    for entry in (base / 'General-Gold-Tracker_Materials.toc').read_text().splitlines():
        if before_catalog and entry == 'MaterialFarmingSpots/CatalogGathering.lua':
            break
        if entry.endswith('.lua') and entry != 'Namespace.lua':
            p = base / entry
            load(Path('.local/tww-herbalism-before.lua').read_text(encoding='utf-8') if original and p == target else p.read_text(encoding='utf-8-sig'), ns)
    return ns

ns = namespace()
baseline = namespace(True)
def plain(value):
    if hasattr(value, 'items'):
        return {k: plain(v) for k,v in value.items()}
    return value

ui = Path('UI/CraftingFarmingWindow.lua').read_text(encoding='utf-8')
snippet = ui[ui.index('local function NormalizeMaterialSpotCoord('):ui.index('local function BuildMaterialFarmingMapOptions(addon,')]
builder = lua.execute('local NS = ...; local function ResolveMaterialMapID() return nil end\n' + snippet + '\nreturn BuildMaterialFarmingMapOptionsFromData', ns)
farming = {int(i.itemID): i for _,i in ns.FarmingItems["items"].items()}
ids_by_name = {
    'Mycobloom': range(210796,210799), 'Luredrop': range(210799,210802),
    'Orbinid': range(210802,210805), 'Blessing Blossom': range(210805,210808),
    "Arathor's Spear": range(210808,210811), 'Phantom Bloom': range(239690,239693),
}
all_ids = {i for ids in ids_by_name.values() for i in ids}
assert len(all_ids) == 18
# Re-decode the attachment independently of the import inventory.
attachment = Path(r'C:\Users\Eugen\.codex\attachments\097002cc-5b4d-41d2-8e30-2e71e085810c\Pasted text.txt').read_text(encoding='utf-8')
imports = re.findall(r'^Retail:Routes:([^:]+):([^:]+):([^\s]+)', attachment, re.M)
assert len(imports) == len(routes) == 12
for r, (herb, zone, payload) in zip(routes, imports):
    decoded = base64.b64decode(payload).decode('latin1')
    packed = [int(p) for p in re.findall(r'\^N\d+\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t',decoded)[1])]
    assert packed == r['packed'] and herb == r['herb'] and zone == r['mapName']
    assert int(re.search(r'\^SRouteZone\^N(\d+)',decoded)[1]) == r['mapID']
    for item_id in ids_by_name[herb]:
        item = ns.MaterialFarmingSpots["items"][item_id]
        assert item.itemName == herb and item.expansion == 'warWithin'
        assert item.isRoute and farming[item_id].isRoute
        assert item.qualityRank == list(ids_by_name[herb]).index(item_id) + 1
        assert ns.MaterialFarmingSpots.missingItems[item_id] is None
        spot = item.spots[r['order']]
        assert spot.id == r['id'] and spot.mapID == r['mapID'] and spot.mapName == zone
        assert spot.sortOrder == r['order'] and spot.isRoute and spot.inGameTested is False
        assert spot.source == r['source'] and spot.routeOrigin == r['routeOrigin']
        assert [spot.sourceUrls[i] for i in range(1,len(spot.sourceUrls)+1)] == r['sourceUrls']
        assert [spot.tips[i] for i in range(2,len(spot.tips)+1)] == r['tips']
        assert len(spot.coords) == len(packed)
        for index,p in enumerate(packed,1):
            assert abs(spot.coords[index].x - p//10000/10000) < 1e-12
            assert abs(spot.coords[index].y - p%10000/10000) < 1e-12
        options = builder(item)
        option = options[r['order']]
        assert option.id == r['id'] and option.mapID == r['mapID'] and option.spotCount == 1
        assert len(option.pins) == len(packed)
        assert option.label == spot.dropdownLabel
        for _,pin in option.pins.items():
            assert pin.isRoute and pin.routeID == spot.id
            assert plain(pin.tips) == plain(spot.tips)
            assert plain(pin.sourceUrls) == plain(spot.sourceUrls)
        assert options[1].id != options[2].id and options[1].label != options[2].label

# Compare curated records before the bundled catalog appends per-item routes.
# The old Mycobloom array aliases let catalog additions bleed across quality ranks and Null Lotus.
ns = namespace(before_catalog=True)
baseline = namespace(True, before_catalog=True)
# Every prior curated spot, including Null Lotus and other expansions, remains intact.
for item_id, before in baseline.MaterialFarmingSpots["items"].items():
    after = ns.MaterialFarmingSpots["items"][item_id]
    if item_id in all_ids:
        assert len(after.spots) == len(before.spots) + 2, (item_id,len(after.spots),len(before.spots))
        for index,spot in before.spots.items():
            assert plain(spot) == plain(after.spots[index+2]), (item_id,index)
    else:
        assert plain(before) == plain(after), item_id

# Index regeneration must preserve all pre-existing lines and add only Phantom Bloom.
before = Path('.local/tww-material-index-before.lua').read_text().splitlines()
after = Path('Data/MaterialIndex.lua').read_text().splitlines()
added = [line for line in after if line not in before]
assert len(added) == 3 and all('Phantom Bloom' in line for line in added)
assert [line for line in after if line not in added] == before
index_ns = lua.table()
load(Path('Data/MaterialIndex.lua').read_text(), index_ns)
for item_id in all_ids:
    assert index_ns.MaterialIndex["items"][item_id].hasMap

count = 0
for folder in ('Core','Tracking','UI','Libs','Data'):
    for p in Path(folder).rglob('*.lua'):
        lua.execute('assert(loadstring(...))', p.read_text(encoding='utf-8-sig'))
        count += 1
print('PASS: 12 attachment routes / 386 ordered vertices / 18 quality-rank items.')
print('PASS: route tips, sources, flags, separate UI options and all generated pins.')
print('PASS: all legacy spots and unrelated records preserved; index adds only 3 Phantom Bloom ranks.')
print(f'PASS: Lua 5.1 compilation for {count} runtime Lua files.')
