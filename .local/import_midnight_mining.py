import base64
import html
import json
import re
from pathlib import Path

attachment = Path(r'C:\Users\Eugen\.codex\attachments\52a51829-4f58-41fb-8476-2f9a3ec06768\Pasted text.txt')
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Mining.lua')
ids_by_name = {'Refulgent Copper Ore': [237359, 237361], 'Umbral Tin Ore': [237362, 237363], 'Brilliant Silver Ore': [237364, 237365], 'Dazzling Thorium': [237366]}
routes = []
for section in re.split(r'^## ', attachment.read_text(encoding='utf-8'), flags=re.M)[1:]:
    heading_name = section.splitlines()[0].strip()
    item_name = 'Refulgent Copper Ore' if heading_name == 'Refulgent Copper' else heading_name
    assert item_name in ids_by_name
    blocks = section.split('### ')[1:]
    assert len(blocks) == 3
    for order, block in enumerate(blocks, 1):
        heading = block.splitlines()[0]
        expected_map, expected_count = map(int, re.search(r'\(map (\d+), (\d+) waypoints\)', heading).groups())
        imported = 'Retail:Routes:' + re.search(r'^Retail:Routes:([^\n]+)', block, re.M)[1].strip()
        import_name, map_name, payload = imported.split(':')[2:]
        assert import_name == heading_name
        serialized = base64.b64decode(payload, validate=True).decode('latin1')
        map_id = int(re.search(r'\^SRouteZone\^N(\d+)', serialized)[1])
        indexed = [(int(i), int(p)) for i,p in re.findall(r'\^N(\d+)\^N(\d+)', re.search(r'\^Sroute\^T(.*?)\^t', serialized)[1])]
        assert map_id == expected_map and len(indexed) == expected_count
        assert [i for i,_ in indexed] == list(range(1, expected_count+1))
        assert '^Slooped^N1' in serialized
        source_url = re.search(r'^Source path: (https?://\S+)', block, re.M)[1]
        tips = [html.unescape(t).strip() for t in re.findall(r'^- (.+)$', block, re.M)]
        assert len(tips) == 3
        label = re.sub(r'\s*\(map \d+, \d+ waypoints\)', '', heading).replace('\u2014', '-').strip()
        slug = re.sub(r'[^a-z0-9]+', '-', item_name.lower()).strip('-')
        routes.append(dict(itemName=item_name, order=order, id=f'midnight-{slug}-{map_id}-{order}-supplied', mapID=map_id, mapName=map_name, location=label, sourceUrl=source_url, tips=tips, packed=[p for _,p in indexed], routeImportString=imported))
assert len(routes) == 12 and sum(len(r['packed']) for r in routes) == 395
Path('.local/midnight-mining-inventory.json').write_text(json.dumps(routes, indent=2), encoding='utf-8')

q = lambda v: json.dumps(v, ensure_ascii=False)
helper = '''-- Supplied Midnight mining exports, decoded without changing vertex order.
-- Mixed-deposit paths from williamlong.info and xScarlife Gaming, not ore-exclusive spawns.
-- Dazzling Thorium is rare bonus loot from base ore nodes and has no dedicated deposit.
local function SuppliedMiningRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrl, routeImportString)
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
        routeType = "mining-loop",
        routeOrigin = "published-zone-gathering-loop",
        source = "Published mixed-deposit path: " .. sourceUrl .. "; supplied per-ore recommendations and tips",
        sourceUrls = { sourceUrl },
        routeImportString = routeImportString,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Published mixed-deposit travel circuit, not guaranteed ore spawns. Dazzling Thorium is rare bonus loot from base ore nodes, not a dedicated deposit.",
    }
end

local SUPPLIED_MINING_ROUTES = {
'''
for name in ids_by_name:
    helper += f'    [{q(name)}] = {{\n'
    for route in (r for r in routes if r['itemName'] == name):
        helper += '        SuppliedMiningRoute(\n'
        helper += f'            {q(route["id"])}, {route["order"]}, {route["mapID"]}, {q(route["mapName"])},\n'
        helper += f'            {q(route["location"])},\n            {{\n'
        for start in range(0,len(route['packed']),8):
            helper += '                ' + ', '.join(map(str,route['packed'][start:start+8])) + ',\n'
        helper += '            },\n            {\n'
        helper += ''.join('                ' + q(tip) + ',\n' for tip in route['tips'])
        helper += '            },\n'
        helper += f'            {q(route["sourceUrl"])},\n            {q(route["routeImportString"])}\n        ),\n'
    helper += '    },\n'
helper += '''}

local function RegisterOre(item)
    -- Own the list so later per-item catalog additions stay within the intended ore/rank.
    local spots = {}
    for _, spot in ipairs(SUPPLIED_MINING_ROUTES[item.itemName] or {}) do
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
before = target.read_bytes()
Path('.local/midnight-mining-before.lua').write_bytes(before)
content = before.decode('utf-8').replace('\r\n','\n')
assert content.count('Register(H.BuildMidnightItem(') == 11
content = content.replace('Register(H.BuildMidnightItem(', 'RegisterOre(H.BuildMidnightItem(', 7)
content = content.replace('local H = NS.MaterialFarmingSpotHelpers\n\n', 'local H = NS.MaterialFarmingSpotHelpers\n\n' + helper, 1)
target.write_bytes(content.replace('\n','\r\n').encode('utf-8') if b'\r\n' in before else content.encode('utf-8'))
catalog = Path('Data/FarmingItems.lua')
before_catalog = catalog.read_bytes()
Path('.local/midnight-mining-farming-items-before.lua').write_bytes(before_catalog)
Path('.local/midnight-mining-herbalism-before.lua').write_bytes(Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Herbalism.lua').read_bytes())
content = before_catalog.decode('utf-8')
for ids in ids_by_name.values():
    for item_id in ids:
        content, count = re.subn(rf'(\{{ itemID = {item_id},[^\r\n]+tag = "Ore")( \}},)', r'\1, isRoute = true\2', content)
        assert count == 1, item_id
catalog.write_bytes(content.encode('utf-8'))
print('Imported 12 mining route variants / 395 ordered points / 36 supplied tips / 7 ore item ranks.')
