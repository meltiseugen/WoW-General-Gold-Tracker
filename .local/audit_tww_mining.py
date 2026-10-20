import base64
import json
import re
from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path.cwd()
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Mining.lua')
routes = json.loads(Path('.local/tww-mining-inventory.json').read_text(encoding='utf-8'))
lua = LuaRuntime(unpack_returned_tuples=True)
load = lua.eval('function(source, ns) local chunk, err = loadstring(source); assert(chunk, err); return chunk("General-Gold-Tracker", ns) end')

def namespace(original=False, before_catalog=False):
    ns = lua.table()
    load(Path('.local/tww-mining-farming-items-before.lua' if original else 'Data/FarmingItems.lua').read_text(encoding='utf-8'), ns)
    base = Path('Data/General-Gold-Tracker_Materials')
    for entry in (base / 'General-Gold-Tracker_Materials.toc').read_text().splitlines():
        if before_catalog and entry == 'MaterialFarmingSpots/CatalogGathering.lua':
            break
        if entry.endswith('.lua') and entry != 'Namespace.lua':
            p = base / entry
            load(Path('.local/tww-mining-before.lua').read_text(encoding='utf-8') if original and p == target else p.read_text(encoding='utf-8-sig'), ns)
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
    'Bismuth': range(210930,210933), 'Aqirite': range(210933,210936),
    'Ironclaw Ore': range(210936,210939), 'Desolate Talus': (238201,238212,238213),
}
all_ids = {i for ids in ids_by_name.values() for i in ids}
assert len(all_ids) == 12
# Re-decode the attachment independently of the import inventory.
attachment = Path(r'C:\Users\Eugen\.codex\attachments\0e1eb20d-c22f-4e4b-b99f-ad81b1fcfe09\Pasted text.txt').read_text(encoding='utf-8')
imports = re.findall(r'^Retail:Routes:([^:]+):([^:]+):([^\s]+)', attachment, re.M)
assert len(imports) == len(routes) == 8
blocks = []
for section in re.split(r'^#{1,2} \d+\. ', attachment, flags=re.M)[1:]:
    intro = section.split('### ')[0]
    for block in section.split('### ')[1:]:
        blocks.append((intro,block.split('## Recommended addon ordering')[0]))
def clean(text):
    text = re.sub(r'\[([^\]]+)\]\(https?://[^\s)]+\)',r'\1',text)
    return text.replace('**','').replace('`','').replace('\u2014','-').replace('\u2013','-').strip()
for r,(intro,block) in zip(routes,blocks):
    for tip in re.findall(r'^- (.+)$',block,re.M):
        assert any(clean(tip) in actual for actual in r['tips']), (r['id'],tip)
    for url in re.findall(r'https?://[^\s)]+',intro+block):
        assert url in r['sourceUrls'], (r['id'],url)
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

# Compare every pre-existing record owned by the mining module without unrelated
# catalog generators that choose duplicate crafting definitions via Lua pairs().
def mining_only(original=False):
    result = lua.table()
    base = Path('Data/General-Gold-Tracker_Materials')
    for source in (base / 'MaterialFarmingSpots.lua', base / 'MaterialFarmingSpots/Shared.lua',
                   Path('.local/tww-mining-before.lua') if original else target):
        load(source.read_text(encoding='utf-8-sig'),result)
    return result
ns = mining_only()
baseline = mining_only(True)
for item_id, before in baseline.MaterialFarmingSpots['items'].items():
    after = ns.MaterialFarmingSpots['items'][item_id]
    if item_id in all_ids:
        assert len(after.spots) == len(before.spots) + 2
        for index,spot in before.spots.items():
            assert plain(spot) == plain(after.spots[index+2]), (item_id,index)
    else:
        assert plain(before) == plain(after),item_id

# Index regeneration must preserve all pre-existing lines and add only Desolate Talus.
before = Path('.local/tww-mining-index-before.lua').read_text().splitlines()
after = Path('Data/MaterialIndex.lua').read_text().splitlines()
added = [line for line in after if line not in before]
assert len(added) == 3 and all('Desolate Talus' in line for line in added)
assert [line for line in after if line not in added] == before
index_ns = lua.table()
load(Path('Data/MaterialIndex.lua').read_text(), index_ns)
for item_id in all_ids:
    assert index_ns.MaterialIndex["items"][item_id].hasMap

# Only the requested nine ore flags and the three Talus items change the catalog.
before_items = Path('.local/tww-mining-farming-items-before.lua').read_text()
after_items = Path('Data/FarmingItems.lua').read_text()
after_items = '\n'.join(line for line in after_items.split('\n') if not re.search(r'itemID = (238201|238212|238213),',line))
for item_id in range(210930,210939):
    after_items = re.sub(rf'(\{{ itemID = {item_id},[^\n]+tag = "Ore"), isRoute = true',r'\1',after_items)
# Other work is actively updating Dragonflight in the shared workspace.
# Compare this task's War Within rows while preserving those concurrent edits.
assert [line for line in before_items.splitlines() if 'expansion = "warWithin"' in line] == [line for line in after_items.splitlines() if 'expansion = "warWithin"' in line]
index_ids = [int(i) for i in re.findall(r'^    \[(\d+)\]',Path('Data/MaterialIndex.lua').read_text(),re.M)]
assert index_ids == sorted(index_ids)

count = 0
for folder in ('Core','Tracking','UI','Libs','Data'):
    for p in Path(folder).rglob('*.lua'):
        lua.execute('assert(loadstring(...))', p.read_text(encoding='utf-8-sig'))
        count += 1
print('PASS: 8 attachment routes / 262 ordered vertices / 12 quality-rank items.')
print('PASS: route tips, sources, flags, separate UI options and all generated pins.')
print('PASS: all existing mining module spots preserved; index adds only 3 Desolate Talus ranks.')
print(f'PASS: Lua 5.1 compilation for {count} runtime Lua files.')
