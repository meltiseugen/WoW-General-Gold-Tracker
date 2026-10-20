import base64
import json
import re
from pathlib import Path

ROOT = Path.cwd()
ATTACHMENT = Path(r'C:\Users\Eugen\.codex\attachments\097002cc-5b4d-41d2-8e30-2e71e085810c\Pasted text.txt')
TARGET = ROOT / 'Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Herbalism.lua'

def clean(text):
    text = re.sub(r'\[([^\]]+)\]\(https?://[^\s)]+\)', r'\1', text)
    return text.replace('**', '').replace('\u2014', '-').replace('\u2013', '-').strip()

def urls(text):
    return list(dict.fromkeys(re.findall(r'https?://[^\s)]+', text)))

def quote(text):
    return json.dumps(text, ensure_ascii=False)

text = ATTACHMENT.read_text(encoding='utf-8')
routes = []
for section in re.split(r'^#{1,2} \d+\. ', text, flags=re.M)[1:]:
    herb = section.splitlines()[0].strip()
    intro = section.split('### ')[0]
    for order, block in enumerate(section.split('### ')[1:], 1):
        block = block.split('## One especially')[0]
        label = clean(block.splitlines()[0])
        imported = re.search(r'^Retail:Routes:([^:]+):([^:]+):([^\s]+)', block, re.M)
        assert imported and imported[1] == herb
        decoded = base64.b64decode(imported[3]).decode('latin1')
        map_id = int(re.search(r'\^SRouteZone\^N(\d+)', decoded)[1])
        geometry = re.search(r'\^Sroute\^T(.*?)\^t', decoded)[1]
        indexed = [(int(i), int(p)) for i, p in re.findall(r'\^N(\d+)\^N(\d+)', geometry)]
        assert [i for i, _ in indexed] == list(range(1, len(indexed) + 1))
        assert '^Slooped^N1' in decoded
        tips = [clean(t) for t in re.findall(r'^- (.+)$', block, re.M)]
        source = clean(re.search(r'\*\*Source:\*\* (.+)', block)[1])
        route_urls = urls(intro + block)
        if herb != 'Phantom Bloom':
            route_urls.append('https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com')
        tips.append('K\'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K\'aresh.')
        route_urls.append('https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com')
        slug = re.sub(r'[^a-z0-9]+', '-', herb.lower()).strip('-')
        routes.append(dict(herb=herb, order=order, id=f'tww-{slug}-{map_id}-{order}-supplied',
                           mapID=map_id, mapName=imported[2], location=label, source=source,
                           routeOrigin='published-herb-route' if herb == 'Phantom Bloom' and order == 1 else 'published-zone-gathering-loop',
                           packed=[p for _, p in indexed], tips=tips, sourceUrls=list(dict.fromkeys(route_urls))))
assert len(routes) == 12

helper = '''-- Supplied Retail Routes exports, decoded without changing vertex order.
-- Most are shared herb/ore travel loops; only the dedicated Phantom Bloom export is herb-specific.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, routeOrigin, source, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    table.insert(tips, 1, "Supplied route provenance: " .. source)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeOrigin = routeOrigin,
        routeType = "herbalism-loop",
        source = source,
        sourceUrls = sourceUrls,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Published gathering travel anchors, not guaranteed node spawns. Follow herb habitat and cave elevation.",
    }
end

local SUPPLIED_HERB_ROUTES = {
'''
for herb in dict.fromkeys(r['herb'] for r in routes):
    helper += f'    [{quote(herb)}] = {{\n'
    for r in [r for r in routes if r['herb'] == herb]:
        helper += '        SuppliedHerbRoute(\n'
        helper += f'            {quote(r["id"])}, {r["order"]}, {r["mapID"]}, {quote(r["mapName"])},\n'
        helper += f'            {quote(r["location"])}, {quote(r["routeOrigin"])}, {quote(r["source"])},\n'
        helper += '            {\n'
        for start in range(0, len(r['packed']), 8):
            helper += '                ' + ', '.join(map(str, r['packed'][start:start+8])) + ',\n'
        helper += '            },\n            {\n'
        helper += ''.join('                ' + quote(t) + ',\n' for t in r['tips'])
        helper += '            },\n            {\n'
        helper += ''.join('                ' + quote(u) + ',\n' for u in r['sourceUrls'])
        helper += '            }\n        ),\n'
    helper += '    },\n'
helper += '''}

local function WithSuppliedRoutes(itemName, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spots[#spots + 1] = spot
    end
    return spots
end

'''

before = TARGET.read_bytes()
(ROOT / '.local/tww-herbalism-before.lua').write_bytes(before)
content = before.decode('utf-8').replace('\r\n', '\n')
marker = 'local function RegisterHerb('
content = content.replace(marker, helper + marker, 1)
content = content.replace('        qualityRank = qualityRank,', '        qualityRank = qualityRank,\n        isRoute = true,', 1)
content = content.replace('        spots = spots,', '        spots = WithSuppliedRoutes(itemName, spots),', 1)
for herb, variable in [('Luredrop', 'LUREDROP_SPOTS'), ('Orbinid', 'ORBINID_SPOTS')]:
    content = content.replace(f'    spots = {variable},', f'    isRoute = true,\n    spots = WithSuppliedRoutes("{herb}", {variable}),')
content += '''
RegisterHerb(239690, "Phantom Bloom", 1,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
RegisterHerb(239691, "Phantom Bloom", 2,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
RegisterHerb(239692, "Phantom Bloom", 3,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
'''
TARGET.write_bytes(content.replace('\n', '\r\n').encode('utf-8') if b'\r\n' in before else content.encode('utf-8'))

path = ROOT / 'Data/FarmingItems.lua'
before_items = path.read_bytes()
(ROOT / '.local/tww-farming-items-before.lua').write_bytes(before_items)
content = before_items.decode('utf-8')
for item_id in range(210796, 210811):
    pattern = rf'(\{{ itemID = {item_id},[^\r\n]+tag = "Herb")( \}},)'
    content, count = re.subn(pattern, r'\1, isRoute = true\2', content)
    assert count == 1, item_id
newline = '\r\n' if b'\r\n' in before_items else '\n'
anchor = next(line for line in content.splitlines() if 'itemID = 210810,' in line)
new = ''.join(newline + f'        {{ itemID = {i}, itemName = "Phantom Bloom", expansion = "warWithin", professions = {{ "herbalism", "alchemy", "inscription" }}, tag = "Herb", isRoute = true }},' for i in range(239690, 239693))
content = content.replace(anchor, anchor + new, 1)
path.write_bytes(content.encode('utf-8'))
(ROOT / '.local/tww-herb-inventory.json').write_text(json.dumps(routes, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'Imported {len(routes)} routes with {sum(len(r["packed"]) for r in routes)} ordered vertices.')
for r in routes:
    print(r['herb'], r['order'], r['mapID'], len(r['packed']), len(r['tips']), len(r['sourceUrls']))
