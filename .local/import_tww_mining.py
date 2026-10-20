import base64
import json
import re
from pathlib import Path

attachment = Path(r'C:\Users\Eugen\.codex\attachments\0e1eb20d-c22f-4e4b-b99f-ad81b1fcfe09\Pasted text.txt')
target = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Mining.lua')
talus_ids = (238201, 238212, 238213)

def clean(text):
    text = re.sub(r'\[([^\]]+)\]\(https?://[^\s)]+\)', r'\1', text)
    return text.replace('**', '').replace('`', '').replace('\u2014', '-').replace('\u2013', '-').strip()

def urls(text):
    return list(dict.fromkeys(re.findall(r'https?://[^\s)]+', text)))

def quote(text):
    return json.dumps(text, ensure_ascii=False)

routes = []
for section in re.split(r'^#{1,2} \d+\. ', attachment.read_text(encoding='utf-8'), flags=re.M)[1:]:
    ore = section.splitlines()[0].strip()
    intro = section.split('### ')[0]
    for order, block in enumerate(section.split('### ')[1:], 1):
        block = block.split('## Recommended addon ordering')[0]
        imported = re.search(r'^Retail:Routes:([^:]+):([^:]+):([^\s]+)', block, re.M)
        assert imported and imported[1] == ore
        decoded = base64.b64decode(imported[3]).decode('latin1')
        map_id = int(re.search(r'\^SRouteZone\^N(\d+)', decoded)[1])
        geometry = re.search(r'\^Sroute\^T(.*?)\^t', decoded)[1]
        indexed = [(int(i), int(p)) for i,p in re.findall(r'\^N(\d+)\^N(\d+)', geometry)]
        assert [i for i,_ in indexed] == list(range(1,len(indexed)+1))
        assert '^Slooped^N1' in decoded
        label = re.sub(r' - Map \d+$', '', clean(block.splitlines()[0]))
        tips = [clean(t) for t in re.findall(r'^- (.+)$', block, re.M)]
        route_urls = urls(intro + block)
        route_urls.append('https://www.wowhead.com/guide/the-war-within/professions/mining-overview')
        if ore == 'Desolate Talus':
            source = 'GamingHero dedicated Desolate Talus ' + ('Mega' if order == 1 else 'Mini') + ' mining export.'
            origin = 'published-ore-route'
            # Retain the supplied consumable tip with its source-specific uncertainty.
            tips = [('Source recommendation (camouflaged Desolate deposits unverified): ' + t) if 'Phial of Truesight' in t else t for t in tips]
        elif ore == 'Aqirite' and order == 2:
            source = 'r/woweconomy Hallowfall Gathering North community export; historical results are not guaranteed yields.'
            origin = 'published-community-gathering-loop'
        else:
            source = 'xScarlife Gaming zone multifarm export selected for ' + ore + '; shared gathering geometry, not ore-exclusive nodes.'
            origin = 'published-zone-gathering-loop'
            route_urls.append('https://xscarlife-gaming.com/farming-retail/')
        if ore != 'Desolate Talus' and not any('Truesight' in t for t in tips):
            tips.append('Keep Phial of Truesight active to reveal camouflaged Khaz Algar ore nodes.')
        slug = re.sub(r'[^a-z0-9]+','-',ore.lower()).strip('-')
        routes.append(dict(herb=ore, order=order, id=f'tww-{slug}-{map_id}-{order}-supplied',
                           mapID=map_id, mapName=imported[2], location=label, source=source,
                           routeOrigin=origin, packed=[p for _,p in indexed], tips=tips,
                           sourceUrls=list(dict.fromkeys(route_urls))))
assert len(routes) == 8

# Match the herbalism implementation while keeping mining data in its owning module.
herbalism = Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/WarWithin/Herbalism.lua').read_text(encoding='utf-8')
helper = herbalism[herbalism.index('local function SuppliedHerbRoute('):herbalism.index('local SUPPLIED_HERB_ROUTES = {')]
helper = '-- Supplied Retail Routes exports in original vertex order; not tested in a running WoW client.\n' + helper.replace('SuppliedHerbRoute','SuppliedOreRoute').replace('herbalism-loop','mining-loop').replace('herb habitat','ore terrain')
helper += 'local SUPPLIED_ORE_ROUTES = {\n'
for ore in dict.fromkeys(r['herb'] for r in routes):
    helper += f'    [{quote(ore)}] = {{\n'
    for r in [r for r in routes if r['herb'] == ore]:
        helper += '        SuppliedOreRoute(\n'
        helper += f'            {quote(r["id"])}, {r["order"]}, {r["mapID"]}, {quote(r["mapName"])},\n'
        helper += f'            {quote(r["location"])}, {quote(r["routeOrigin"])}, {quote(r["source"])},\n            {{\n'
        for start in range(0,len(r['packed']),8):
            helper += '                ' + ', '.join(map(str,r['packed'][start:start+8])) + ',\n'
        helper += '            },\n            {\n'
        helper += ''.join('                '+quote(t)+',\n' for t in r['tips'])
        helper += '            },\n            {\n'
        helper += ''.join('                '+quote(u)+',\n' for u in r['sourceUrls'])
        helper += '            }\n        ),\n'
    helper += '    },\n'
helper += '''}

local function WithSuppliedRoutes(itemName, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_ORE_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spots[#spots + 1] = spot
    end
    return spots
end

'''
before = target.read_bytes()
Path('.local/tww-mining-before.lua').write_bytes(before)
content = before.decode().replace('\r\n','\n')
content = content.replace('local function RegisterOre(',helper+'local function RegisterOre(',1)
content = content.replace('        qualityRank = qualityRank,','        qualityRank = qualityRank,\n        isRoute = true,',1)
content = content.replace('        spots = spots or H.TWW_MINING_SPOTS,','        spots = WithSuppliedRoutes(itemName, spots or H.TWW_MINING_SPOTS),',1)
for rank,item_id in enumerate(talus_ids,1):
    content += f'\nRegisterOre({item_id}, "Desolate Talus", {rank},\n    "K\'aresh mining and Resource Market exchange material. Choose the dedicated Mega or Mini route.", {{}})\n'
target.write_bytes(content.replace('\n','\r\n').encode() if b'\r\n' in before else content.encode())

path = Path('Data/FarmingItems.lua')
before = path.read_bytes()
Path('.local/tww-mining-farming-items-before.lua').write_bytes(before)
content = before.decode()
for item_id in range(210930,210939):
    content,count = re.subn(rf'(\{{ itemID = {item_id},[^\r\n]+tag = "Ore")( \}},)',r'\1, isRoute = true\2',content)
    assert count == 1,item_id
newline = '\r\n' if b'\r\n' in before else '\n'
anchor = next(line for line in content.splitlines() if 'itemID = 210938,' in line)
new = ''.join(newline+f'        {{ itemID = {i}, itemName = "Desolate Talus", expansion = "warWithin", professions = {{ "mining" }}, tag = "Ore", isRoute = true }},' for i in talus_ids)
path.write_bytes(content.replace(anchor,anchor+new,1).encode())

path = Path('Data/MaterialIndex.lua')
before = path.read_bytes()
Path('.local/tww-mining-index-before.lua').write_bytes(before)
content = before.decode()
newline = '\r\n' if b'\r\n' in before else '\n'
anchor = next(line for line in content.splitlines() if (m:=re.match(r'    \[(\d+)\]',line)) and int(m[1]) > max(talus_ids))
new = ''.join(f'    [{i}] = {{ itemID = {i}, itemName = "Desolate Talus", expansion = "warWithin", professions = {{ "mining" }}, hasMap = true }},'+newline for i in talus_ids)
path.write_bytes(content.replace(anchor,new+anchor,1).encode())
Path('.local/tww-mining-inventory.json').write_text(json.dumps(routes,ensure_ascii=False,indent=2),encoding='utf-8')
print(f'Imported {len(routes)} routes with {sum(len(r["packed"]) for r in routes)} ordered vertices.')
for r in routes:
    print(r['herb'],r['order'],r['mapID'],len(r['packed']),len(r['tips']),len(r['sourceUrls']))
