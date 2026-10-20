import sys
sys.path.insert(0,'.local')
from midnight_specialty_research import *
from lupa.lua51 import LuaRuntime

D=json.loads((T/'discovery.json').read_text()); recipes=json.loads((T/'selected-recipes.json').read_text(encoding='utf-8'))
vendor=set(json.loads((T/'excluded-vendor.json').read_text())); selected={r['itemID'] for r in recipes}
lua=LuaRuntime(unpack_returned_tuples=True);ns=lua.table()
load=lua.eval('function(s,n) assert(loadstring(s))("General-Gold-Tracker",n) end')
load(Path('Data/FarmingItems.lua').read_text(encoding='utf-8'),ns)
base=Path('Data/General-Gold-Tracker_Materials')
for line in (base/'General-Gold-Tracker_Materials.toc').read_text().splitlines():
    if line=='MaterialFarmingSpots/CatalogGathering.lua':break
    if line.endswith('.lua') and line!='Namespace.lua':load((base/line).read_text(encoding='utf-8-sig'),ns)
existing={int(i):v for i,v in ns.MaterialFarmingSpots['items'].items() if v.expansion=='midnight'}
raw={}
def add(i,professions,category,summary,tips,sources=(),**extra):
    item=cached('item',i)
    assert item.get('name') and item.get('tooltip'),i
    assert i not in vendor and i not in selected,i
    record=dict(itemID=i,itemName=item['name'],expansion='midnight',professions=professions,category=category,isRoute=False,auctionable=not bound(i),summary=summary,tips=tips,sourceUrls=list(dict.fromkeys([f'https://www.wowhead.com/item={i}']+list(sources))),spots=[],preserveExistingSpots=i in existing,acquisitionType=extra.pop('acquisitionType','specialty-farm'))
    record.update(extra)
    if not record['auctionable']:record['supportOnly']=True
    rank=re.search(r'(\+{1,3})$',D['names'].get(str(i),''))
    if rank:record['qualityRank']=len(rank[1])
    raw[i]=record

species='https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine'
majestic='https://www.method.gg/guides/midnight-majestic-beast-lure-locations'
cloth='https://www.method.gg/guides/best-bright-linen-cloth-farming-locations'
fish='https://www.wow-professions.com/guides/wow-fishing-leveling-guide'
patch='https://www.wow-professions.com/news/midnight-patch-12-1-knowledge-point-reset'
for i,item in existing.items():
    if item.category in ['Ore','Herb'] or i in selected or i in vendor:continue
    add(i,[v for _,v in item.professions.items()],item.category,item.summary or 'Tradeable Midnight profession material.',
        ['Follow the sourced search areas and item-specific acquisition notes. Markers do not guarantee spawns or measured yields.'],
        [v for _,v in (item.sourceUrls or lua.table()).items()])
for i in [238511,238512,238513,238514,238518,238519,238520,238521]:
    if i not in selected:
        add(i,['skinning','leatherworking'],'Hide' if i in [238518,238519] else 'Plating' if i in [238520,238521] else 'Leather' if i in [238511,238512] else 'Scale',
            'Tradeable Midnight skinning reagent; leather and hides come from leathery beasts, scales and plating from scaled beasts.',
            ['Learn Midnight Skinning and skin eligible beasts after looting them.','Thorough Tanning unlocks Sharpen Your Knife for a rare hide or plating on the next eligible skin; check the current ability cooldown.'],
            ['https://www.method.gg/guides/midnight-skinning-profession-guide'],reuseFrom=238518 if i==238519 else None)
for i,kind in [(238522,'feathered'),(238523,'fanged'),(238525,'furred')]:
    raw[i].update(summary=f'Species-specific Midnight skinning material from {kind} beasts; Gainful Gathering must be unlocked.',tips=['Unlock Gainful Gathering to become eligible for species reagents; Trophy Taker improves collection.','Choose the matching beast family. Some fanged and furred beasts may overlap.','The source reported unusually low drops near launch; it is not evidence of a current guaranteed rate.'],sourceUrls=[f'https://www.wowhead.com/item={i}',species])
for i in [238528,238529,238530]:
    raw[i].update(summary='Rare material from skinning Renowned Beasts summoned with Midnight beast lures.',tips=['Unlock Talented Tracker and Majestic Materials before investing in the lure farm.','Use the zone-specific lure at its designated location; Sixth Sense is easier to notice while unmounted.','Check daily eligibility and the current lure cooldown. A Majestic reagent is chance-based, not promised from every skin.'],sourceUrls=[f'https://www.wowhead.com/item={i}',majestic,'https://www.method.gg/guides/midnight-skinning-profession-guide'])
    raw[i]['spots']=[dict(id=f'midnight-majestic-{i}-{m}-{n}',mapID=m,mapName=z,location=loc,routeType='lure-summon',isRoute=False,coords=[dict(x=x,y=y,label=loc)]) for n,(m,z,loc,x,y) in enumerate([(2395,'Eversong Woods','Gloomclaw lure placement',.4194,.7971),(2437,"Zul'Aman",'Silverscale lure placement',.4756,.5263),(2413,'Harandar','Lumenfin lure placement',.6661,.4784),(2405,'Voidstorm','Umbrafang lure placement',.5412,.6523),(2405,'Voidstorm','Netherscythe Grand Beast lure placement',.4324,.8283)],1)]
    raw[i]['preserveExistingSpots']=False
for i in [236963,236965,237015,237016,237017,237018]:
    raw[i].update(tips=['Midnight Tailoring and Fabric Specialist improve eligible humanoid cloth farming.','Sunfire Silk Weaving and Arcanoweaving unlock the corresponding specialty cloth; regular Bright Linen needs no specialty-cloth unlock.','Shadowguard Point and the Grudge Pit are sourced solo search areas. Clear eligible humanoids, loot and leave; difficulty, resets and yield can change.'],sourceUrls=[f'https://www.wowhead.com/item={i}',cloth])
    raw[i]['spots']=[dict(id=f'midnight-cloth-{i}-{m}',mapID=m,mapName=z,location=loc,routeType='instance-search',isRoute=False,coords=[dict(x=x,y=y,label=loc)]) for m,z,loc,x,y in [(2405,'Voidstorm','Shadowguard Point delve entrance',.3738,.4774),(2413,'Harandar','The Grudge Pit delve entrance',.7030,.6714)]]
    raw[i]['preserveExistingSpots']=False

# Add the new Coiled Isle fish, along with the established 20 launch fish.
for i in D['itemIDs']:
    item=cached('item',i);text=plain(item.get('tooltip',''))
    if D['professions'][str(i)]!='fishing' or bound(i) or 'Crafting Reagent' not in text or 'fish' not in text.lower() or i in selected:continue
    if re.match(r'Ace |Two |Three ',item.get('name','')):continue
    if i not in raw:
        add(i,['fishing','cooking'],'Fish','Tradeable fish from The Coiled Isle in Midnight Patch 12.1.',
            ['Check the item fishing locations and the correct Coiled Isle water or pool type.','Some catches require venom-fishing access or specific pools. Campaign and Captain Tokka reputation requirements can apply.','Sell the raw catch or compare its eligible cooking and lure uses; no guaranteed hourly catch rate is assigned.'],[patch,f'https://www.wowhead.com/item={i}'],acquisitionType='fishing')
for i in [242606,242608,242610,242611,242613,242620,242788]:
    add(i,['jewelcrafting'],'Gem Processing','Tradeable Midnight prospecting or gem-crushing material.',
        ['Prospect eligible Midnight ore for gems, glass and stone; crush eligible gems for Glimmering Gemdust.','These are processed outputs, not additional raw ore farms. Source material, skill and specialization affect random returns.'],
        ['https://www.wow-professions.com/midnight/jewelcrafting-guide'],randomOutput=True,acquisitionType='gem-crushing' if i==242620 else 'prospecting')
for i in [245803,245807,245865,245867]:
    add(i,['inscription'],'Pigment','Tradeable pigment produced by milling the corresponding Midnight herb.',
        ['Use Midnight Milling and the appropriate herb source; processed pigments are distinct from raw herb entries.','Milling quantities vary. No fixed per-pigment input ratio or guaranteed return is encoded.'],['https://www.wow-professions.com/midnight/inscription-guide'],randomOutput=True,acquisitionType='milling')
for i in [243578,243579,243581,243582]:
    if i in selected:continue
    add(i,['engineering'],'Recycled Reagent','Tradeable Midnight Engineering recycling reagent used by profession equipment, gadgets and decor.',
        ['Recycle eligible Midnight reagents using the Engineering Recycling ability; this is a processing source, not an outdoor deposit.','Source item and quality determine the result. Comments report blue crafted reagents such as Soul Sprocket or Imbued Bright Linen Bolt for Aetherlume and common reagents for Evercore. Verify the current output before bulk processing.','Compare raw input sale value against the returned reagent; no fixed conversion yield is assumed.'],['https://www.wow-professions.com/midnight/engineering-guide'],randomOutput=True,acquisitionType='engineering-recycling')
for i in [253307,256559]:
    add(i,['blacksmithing','jewelcrafting','tailoring','leatherworking','engineering','inscription'],'PvP Reagent',
        'Tradeable Midnight PvP crafting reagent with activity rewards as well as an Honor purchase option.',
        ['The current item tooltip explicitly lists PvP activities as an acquisition source, so this is not vendor-only.','Reward eligibility and PvP season matter. Galactic Combatant heraldry is the Season 1 baseline accepted by the recorded Competitor recipes; other eligible heraldry may differ.'],[f'https://www.wowhead.com/item={i}'],acquisitionType='pvp-reward')
for i in [274777,274781]:
    add(i,['skinning','alchemy','enchanting','leatherworking','tailoring','blacksmithing','engineering','cooking','inscription','jewelcrafting'],'Coiled Isle Reagent',
        'Tradeable Patch 12.1 specialty reagent from The Coiled Isle; guides report cursed-window gathering and skinning sources.',
        ['Complete a Curse Surge and look for the Cursed Land and Waters window before checking the relevant gathering sources.','Neutralized Venom Clot comes from cleansing Envenomated sources and collecting the resulting green orbs; Cursebound Globe comes from Cursed sources.','Skinning is an additional reported source. These are specialty byproducts, not ore or herb catalog entries; source eligibility and quantities vary.'],[patch,'https://www.method.gg/guides/farming-routes-for-neutralized-venom-clot-and-cursebound-globes-in-wow-midnight'],randomOutput=True)
add(253403,['cooking'],'Processed Fish','Tradeable Thalassian Fillet produced by Midnight Cooking fish preparation.',
    ['Use the matching fillet recipe and eligible fish. Source fish and cooking setup affect returns.','This is a processed fish product; no invented deterministic fish-to-fillet yield is assigned.'],['https://www.wow-professions.com/guides/wow-cooking-leveling-guide'],randomOutput=True,acquisitionType='cooking-processing')
for i in [242651,256963]:
    add(i,['alchemy'] if i==242651 else ['miscellaneous'],'Bound Crafting Support',
        'Bound Alchemy recycling reagent required by Midnight transmutes; cannot be sold on the Auction House.' if i==242651 else 'Warband-bound Thalassian Lumber harvested for Midnight housing crafts; cannot be sold on the Auction House.',
        ['Retained only to explain the required inputs of saleable products. This is not an AH farming target.','Recycle eligible alchemical items for Stabilized Derivate.' if i==242651 else 'Harvest eligible lumber nodes in Midnight zones after unlocking lumber gathering; do not buy it as an AH material.'],['https://www.wow-professions.com/midnight/alchemy-guide' if i==242651 else 'https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era'],acquisitionType='bound-support')

# Cards are loot/crafting outcomes; the four complete decks have exact eight-card compositions.
for i in D['itemIDs']:
    item=cached('item',i);name=item.get('name','')
    if D['professions'][str(i)]=='inscription' and re.match(r'(Ace|Two|Three|Four|Five|Six|Seven|Eight) of (Hunt|Void|Rot|Blood)$',name):
        add(i,['inscription'],'Darkmoon Card','Tradeable Midnight Darkmoon card used to assemble its matching eight-card deck.',
            ['Collect the matching Ace through Eight to assemble a full deck.','Cards are chance-based loot or profession outcomes; there is no guaranteed conversion from a single herb or reagent to a chosen card.'],['https://www.wow-professions.com/midnight/inscription-guide'],randomOutput=True,acquisitionType='darkmoon-card')
for i in [262792,262797]:
    add(i,['fishing'],'Fishing Line Fragment','Tradeable Midnight fishing-line fragment found while fishing and opening fishing treasure.',
        ['Keep fragments for their documented combination chain, or sell them separately.','Careless Cargo, Lost Treasures and Patient Treasures are reported sources. Source pool and reward eligibility matter.'],[fish],acquisitionType='fishing-treasure')

# Tradeable recipe drops and unusual cosmetics found by fishing. The containing bottle is Warband-bound.
for i in D['itemIDs']:
    v=cached('item',i);name=v.get('name','')
    if D['professions'][str(i)]!='fishing' or i in selected or i in raw or bound(i) or not name:continue
    if i in D['removedIDs'] or i in D['futureIDs']:continue
    if name.startswith(('Recipe:','Design:','Plans:','Pattern:','Schematic:','Technique:')):
        add(i,['fishing'],'Fishing Recipe Drop','Tradeable profession recipe listed among Midnight fishing rewards.',
            ['Fish Careless Cargo or Lost Treasures and open eligible fishing recipe rewards.','Thalassian Recipe in a Bottle is Warband-bound; the recipe inside must be checked individually for tradeability. Duplicates and profession eligibility affect which recipes appear.'],['https://www.wowhead.com/item=278329',fish],acquisitionType='fishing-recipe-drop')
    elif name.startswith(('Lost ','Sanctum ','Farstrider\'s ')) or i in [238489,238494,266102,262650,262651]:
        add(i,['fishing'],'Fishing Specialty','Unbound Midnight fishing reward, cosmetic or unusual catch.',
            ['Consult the item source and fish the eligible Midnight waters or treasure pools.','Cosmetics must remain unlearned or unequipped for sale. No sale price or guaranteed catch rate is assumed.'],[fish],acquisitionType='fishing-specialty')

# Resolve every selected craft component, excluding vendor-only supplies and existing ore/herb references.
known={int(i) for i in re.findall(r'itemID = (\d+),',Path('Data/FarmingItems.lua').read_text(encoding='utf-8'))}
missing={x['itemID'] for r in recipes for x in r['components']}-known-selected-set(raw)
assert not missing,[(i,cached('item',i).get('name')) for i in missing]
assert not(set(raw)&selected)
save('selected-specialties.json',list(raw.values()))
print('Specialty records',len(raw),'saleable',sum(v['auctionable'] for v in raw.values()),'bound support',sum(not v['auctionable'] for v in raw.values()))
