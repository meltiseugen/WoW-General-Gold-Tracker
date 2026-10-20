import base64
import html
import json
import re
from pathlib import Path

ATTACHMENT = Path(r'C:\Users\Eugen\.codex\attachments\83f00319-6b3e-4a7a-926c-a63d014752c8\Pasted text.txt')
TARGET = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Herbalism.lua')

def clean(value):
    return html.unescape(value).replace('\u00a0', ' ').strip()

def decode(import_string):
    payload = import_string.rsplit(':', 1)[1]
    serialized = base64.b64decode(payload, validate=True).decode('latin1')
    points = [(int(i), int(p)) for i, p in re.findall(r'\^N(\d+)\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t', serialized)[1])]
    assert [i for i, _ in points] == list(range(1, len(points)+1))
    assert '^Slooped^N1' in serialized
    return int(re.search(r'\^SRouteZone\^N(\d+)', serialized)[1]), [p for _, p in points]

text = ATTACHMENT.read_text(encoding='utf-8')
zones = {'Eversong Woods': 2395, "Zul'Aman": 2437, 'Harandar': 2413, 'Voidstorm': 2405}
geometry = {}
imports = {}
for import_string in re.findall(r'^Retail:Routes:[^\s]+(?:[^\n]*)', text, re.M):
    herb, zone = import_string.split(':')[2:4]
    map_id, points = decode(import_string)
    assert map_id == zones[zone]
    if zone in geometry:
        assert geometry[zone] == points, (herb, zone)
    geometry[zone] = points
    imports[herb] = import_string
void_import = json.loads(Path('.local/midnight-voidstorm-source.json').read_text(encoding='utf-8-sig'))['content'].strip()
void_map, geometry['Voidstorm'] = decode(void_import)
assert void_map == 2405 and len(geometry['Voidstorm']) == 42
assert {zone: len(points) for zone, points in geometry.items()} == {'Eversong Woods': 25, 'Harandar': 36, "Zul'Aman": 19, 'Voidstorm': 42}

source = 'https://xscarlife-gaming.com/farming/retail/'
zone_guide = 'https://www.method.gg/guides/midnight-herb-and-mote-farming-routes'
argent_guide = 'https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route'
lotus_guide = 'https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight'
leveling = 'https://www.wow-professions.com/guides/wow-herbalism-leveling-guide'
azeroot_forum = 'https://us.forums.blizzard.com/en/wow/t/azeroot-nightmare/2272323'
item_ids = {'Tranquility Bloom': [236761, 236767], 'Argentleaf': [236776, 236777], 'Azeroot': [236774, 236775], 'Mana Lily': [236778, 236779], 'Sanguithorn': [236770, 236771], 'Nocturnal Lotus': [236780]}
routes = []
for section in re.split(r'^## \d+\. ', text, flags=re.M)[1:]:
    herb = section.splitlines()[0].strip()
    assert herb in item_ids
    section = section.split('## Addon integration')[0]
    for order, block in enumerate(section.split('### ')[1:], 1):
        heading = block.splitlines()[0]
        zone = next(z for z in zones if z in heading)
        label = ('Main' if order == 1 else f'Alternative {order-1}') + ' - ' + zone
        tips = [clean(t) for t in re.findall(r'^- (.+)$', block, re.M)]
        assert len(tips) == 3, (herb, label, tips)
        urls = [source, zone_guide, f'https://www.wowhead.com/item={item_ids[herb][0]}']
        if herb == 'Tranquility Bloom':
            urls.append(leveling if order == 1 else argent_guide if zone == 'Harandar' else zone_guide)
        elif herb == 'Argentleaf':
            urls.append(argent_guide)
        elif herb == 'Azeroot':
            urls += [azeroot_forum, argent_guide]
        elif herb == 'Mana Lily':
            urls.append(leveling)
        elif herb == 'Nocturnal Lotus':
            urls += [lotus_guide, leveling]
        slug = re.sub(r'[^a-z0-9]+', '-', herb.lower()).strip('-')
        routes.append(dict(herb=herb, order=order, id=f'midnight-{slug}-{zones[zone]}-{order}-supplied', mapID=zones[zone], mapName=zone, location=label, packed=geometry[zone], tips=tips, sourceUrls=list(dict.fromkeys(urls)), routeImportString=imports[herb] if order == 1 else void_import if zone == 'Voidstorm' else None))
assert len(routes) == 18 and sum(len(r['packed']) for r in routes) == 543
Path('.local/midnight-herb-inventory.json').write_text(json.dumps(routes, indent=2), encoding='utf-8')

q = lambda v: json.dumps(v, ensure_ascii=False)
helper = '''-- Supplied Midnight herb recommendations use xScarlife's shared multifarm loops.
-- Eversong, Harandar and Zul'Aman vertices are decoded from the attachment.
-- Its omitted Voidstorm export was recovered from the publisher's public route library.
-- These are travel paths, not guaranteed herb spawns or measured herb-specific yield rankings.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls, routeImportString)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = {
            x = math.floor(packed / 10000) / 10000,
            y = (packed % 10000) / 10000,
            label = location .. " #" .. index,
        }
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeType = "herbalism-loop",
        routeOrigin = "published-zone-gathering-loop",
        source = "xScarlife Gaming published multifarm path; supplied per-herb recommendations and tips",
        sourceUrls = sourceUrls,
        routeImportString = routeImportString,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Mixed-herb travel circuit; follow nearby herb habitats. Not a measured single-herb yield ranking or a guarantee of node spawns.",
    }
end

local ZONE_ROUTE_COORDS = {
'''
for zone, points in geometry.items():
    helper += f'    [{zones[zone]}] = {{\n'
    for start in range(0, len(points), 8):
        helper += '        ' + ', '.join(map(str, points[start:start+8])) + ',\n'
    helper += '    },\n'
helper += '}\n\nlocal SUPPLIED_HERB_ROUTES = {\n'
for herb in item_ids:
    helper += f'    [{q(herb)}] = {{\n'
    for route in (r for r in routes if r['herb'] == herb):
        helper += '        SuppliedHerbRoute(\n'
        helper += f'            {q(route["id"])}, {route["order"]}, {route["mapID"]}, {q(route["mapName"])},\n'
        helper += f'            {q(route["location"])}, ZONE_ROUTE_COORDS[{route["mapID"]}],\n'
        helper += '            {\n' + ''.join('                ' + q(tip) + ',\n' for tip in route['tips']) + '            },\n'
        helper += '            {\n' + ''.join('                ' + q(url) + ',\n' for url in route['sourceUrls']) + '            }'
        if route['routeImportString']:
            helper += ',\n            ' + q(route['routeImportString'])
        helper += '\n        ),\n'
    helper += '    },\n'
helper += '''}

local function RegisterHerb(item)
    -- Each rank owns its spot list, so later catalog additions cannot bleed into other herbs/ranks.
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[item.itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(item.spots or {}) do
        spots[#spots + 1] = spot
    end
    item.spots = spots
    item.isRoute = true
    Register(item)
end

'''
before = TARGET.read_bytes()
Path('.local/midnight-herbalism-before.lua').write_bytes(before)
content = before.decode('utf-8').replace('\r\n', '\n')
content = content.replace('Register(H.BuildMidnightItem(', 'RegisterHerb(H.BuildMidnightItem(')
content = content.replace('local H = NS.MaterialFarmingSpotHelpers\n\n', 'local H = NS.MaterialFarmingSpotHelpers\n\n' + helper, 1)
TARGET.write_bytes(content.replace('\n', '\r\n').encode('utf-8') if b'\r\n' in before else content.encode('utf-8'))
catalog_path = Path('Data/FarmingItems.lua')
before_catalog = catalog_path.read_bytes()
Path('.local/midnight-farming-items-before.lua').write_bytes(before_catalog)
content = before_catalog.decode('utf-8')
for ids in item_ids.values():
    for item_id in ids:
        content, count = re.subn(rf'(\{{ itemID = {item_id},[^\r\n]+tag = "Herb")( \}},)', r'\1, isRoute = true\2', content)
        assert count == 1, item_id
catalog_path.write_bytes(content.encode('utf-8'))
print(f'Imported {len(routes)} route variants / {sum(len(r["packed"]) for r in routes)} ordered points / {sum(map(len,item_ids.values()))} item ranks.')
