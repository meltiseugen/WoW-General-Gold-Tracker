import sys
sys.path.insert(0,'.local')
from midnight_specialty_research import *

raw=json.loads((T/'selected-specialties.json').read_text(encoding='utf-8'))
seasonal_ids={33226,252990,253043}
for i in sorted(seasonal_ids):
    assert bound(i) and cached('item',i).get('name')
    raw.append(dict(itemID=i,itemName=cached('item',i)['name'],expansion='midnight',professions=['inscription','tailoring'],category='Bound Seasonal Crafting Support',isRoute=False,auctionable=False,supportOnly=True,summary='Bound Hallow\'s End reward required by a saleable Midnight seasonal housing craft; cannot be sold on the Auction House.',tips=['Retained only as a required crafting input, not an AH farming target.','Earn Tricky Treats through holiday candy buckets and activities. Neighborhood candy comes from themed neighborhood quests and holiday rewards; event availability applies.'],sourceUrls=[f'https://www.wowhead.com/item={i}','https://www.wowhead.com/guide/world-events/holidays/hallows-end'],spots=[],preserveExistingSpots=False,acquisitionType='bound-seasonal-support'))
save('selected-specialties.json',raw)

# Reuse the row serializer and metadata builder without repeating the original mutations.
script=Path('.local/midnight_specialty_apply.py').read_text(encoding='utf-8')
exec(script[:script.index('assert len({r[\'itemID\']')])
added_ids=seasonal_ids|{282184,282190}
new_rows=[r for r in rows if r['itemID'] in added_ids]
assert len(new_rows)==5
for row in new_rows:
    if row['itemID'] in {282184,282190}:row['recipeSourceLabel']+='; Hallow\'s End seasonal unlock and holiday ingredients required; craft during event availability'
path=Path('Data/FarmingItems.lua');text=path.read_text(encoding='utf-8');assert text.endswith('    },\n}\n')
text=text[:-len('    },\n}\n')]+''.join('        '+lua(r)+',\n' for r in new_rows)+'    },\n}\n'
text=text.replace('783 verified compositions and 76 saleable housing crafts','785 verified compositions and 78 saleable housing crafts')
path.write_text(text,encoding='utf-8',newline='\n')
path=Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight/Miscellaneous.lua');text=path.read_text(encoding='utf-8')
anchor='}\n\nlocal mapIDs = '
assert text.count(anchor)==1
text=text.replace(anchor,''.join('    '+lua(r)+',\n' for r in raw if r['itemID'] in seasonal_ids)+anchor)
path.write_text(text,encoding='utf-8',newline='\n')
for row in rows:
    if row['itemID'] in {282184,282190}:row['recipeSourceLabel']=next(r['recipeSourceLabel'] for r in new_rows if r['itemID']==row['itemID'])
save('all-research-rows.json',rows)
counts=json.loads((T/'audit-counts.json').read_text())
counts.update(newEntries=886,newSaleable=881,boundSupport=5,compositions=785,housingRecipes=78,specialties=165,newIndexEntries=887)
counts['byProfession']['inscription']+=1;counts['byProfession']['tailoring']+=1
save('audit-counts.json',counts)
sources=json.loads((T/'sources.json').read_text());sources.update({'hallows-end':'https://www.wowhead.com/guide/world-events/holidays/hallows-end','patch-12-1-5':'https://worldofwarcraft.blizzard.com/en-us/news/24304162'});save('sources.json',sources)
exec(script[script.index('report=dict('):])

from lupa.lua51 import LuaRuntime
LuaRuntime().execute(Path('tools/generate_material_index.lua').read_text())
path=Path('Data/MaterialIndex.lua');before=Path('.local/midnight-specialty/before-Data__MaterialIndex.lua').read_text().splitlines();after=path.read_text().splitlines()
original={int(re.search(r'\[(\d+)\]',line)[1]):line for line in before if re.search(r'^    \[\d+\]',line)}
result=[]
for line in after:
    match=re.search(r'^    \[(\d+)\]',line)
    if not match:result.append(line);continue
    item_id=int(match[1])
    if item_id in original and 'expansion = "midnight"' not in original[item_id]:result.append(original[item_id])
    elif item_id in original or 'expansion = "midnight"' in line:result.append(line)
path.write_text('\n'.join(result)+'\n',encoding='utf-8')
print('Added both current seasonal housing crafts and their three bound, farmable holiday inputs.')
