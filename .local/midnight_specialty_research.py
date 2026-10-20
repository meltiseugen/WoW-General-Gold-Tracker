import concurrent.futures, csv, html, io, json, os, re, shutil, sys, urllib.request, urllib.parse
from collections import Counter, defaultdict
from pathlib import Path

R = Path.cwd()
T = R / '.local/midnight-specialty'
T.mkdir(exist_ok=True)
def plain(v): return re.sub(r'\s+',' ',html.unescape(re.sub('<[^>]+>',' ',v))).strip()
def save(n,v): (T/n).write_text(json.dumps(v,indent=2,ensure_ascii=False),encoding='utf-8')
def download(url,name):
    path=T/name
    if path.exists(): return path.read_text(encoding='utf-8')
    req=urllib.request.Request(url,headers={'User-Agent':'Mozilla/5.0'})
    with urllib.request.urlopen(req,timeout=35) as response: value=response.read().decode('utf-8-sig')
    path.write_text(value,encoding='utf-8');return value
def cached(kind,i):
    path=T/f'{kind}-{i}.json'
    return json.loads(path.read_text(encoding='utf-8')) if path.exists() else {}
def fetch(kind,i):
    try: return json.loads(download(f'https://nether.wowhead.com/tooltip/{kind}/{i}',f'{kind}-{i}.json'))
    except Exception as e:return {'error':str(e)}
def many(jobs):
    jobs=list(dict.fromkeys(jobs));errors=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        for index,(job,result) in enumerate(zip(jobs,pool.map(lambda j:fetch(*j),jobs)),1):
            if 'error' in result:errors.append([job,result['error']])
            if index%100==0:print(f'Tooltips {index}/{len(jobs)}',flush=True)
    save('fetch-errors.json',errors);print('Tooltips',len(jobs),'errors',len(errors),flush=True)
def bound(i):
    raw=cached('item',i).get('tooltip','')
    own=raw.split('<!--bo-->')[-1].split('<!--ue-->')[0] if '<!--bo-->' in raw else raw.split('</table>')[0]
    return bool(re.search(r'Binds when picked up|Binds to|Warbound|Quest Item|Conjured Item',plain(own)))

def discover():
    files=['Data/FarmingItems.lua','Data/MaterialIndex.lua','Data/General-Gold-Tracker_Materials/General-Gold-Tracker_Materials.toc','Data/General-Gold-Tracker_Materials/MaterialFarmingSpots.lua','tests/data/farming_data_spec.lua']
    files += [p.as_posix() for p in Path('Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Midnight').glob('*.lua')]
    for filename in files:
        snapshot=T/('before-'+filename.replace('/','__'))
        if not snapshot.exists():shutil.copyfile(R/filename,snapshot)
    sources={
        'att-midnight.lua':'https://raw.githubusercontent.com/ATTWoWAddon/AllTheThings/master/.contrib/.db/standard/09%20-%20Crafted%20Items/12%20-%20Midnight.lua',
        'reagents-db.lua':'https://raw.githubusercontent.com/ATTWoWAddon/AllTheThings/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua',
        'housing-blizzard.html':'https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era',
    }
    for name,url in sources.items():
        print(name,len(download(url,name)),flush=True)
    save('sources.json',sources)
    raw=(T/'att-midnight.lua').read_text(encoding='utf-8')
    raw=re.sub(r'--\[\[.*?(?:--)?\]\]','',raw,flags=re.S)
    professions={};names={};housing=set();removed=set();future=set();explicit=set();profession=None
    for line in raw.splitlines():
        match=re.search(r'prof\((\w+),',line)
        if match:profession=match[1].lower()
        match=re.search(r'\bi\((\d+)',line)
        if match:
            i=int(match[1]);names[i]=line.split('--',1)[-1].strip()
            if profession:professions[i]=profession
            if '(DECOR!)' in line:housing.add(i)
            if 'REMOVED' in line:removed.add(i)
            if re.search(r'ADDED_12_[2-9]|ADDED_12_1_[57]',line):future.add(i)
        explicit.update(int(i) for i in re.findall(r'\b(?:r|spell|fc|r_withQuest)\((\d+)',line))
    db=(T/'reagents-db.lua').read_text(encoding='utf-8')
    outputs={int(s):int(i) for s,i in re.findall(r'\[(\d+)\]\s*=\s*\{\s*(\d+)\s*,\s*\d+\s*\}',db)}
    spells={s for s,i in outputs.items() if i in professions}|explicit
    save('discovery.json',dict(itemIDs=sorted(professions),professions=professions,names=names,housingIDs=sorted(housing),removedIDs=sorted(removed),futureIDs=sorted(future),spellIDs=sorted(spells),spellOutputs=outputs))
    print('Discovered',len(professions),'items',len(spells),'spells',len(housing),'decor',Counter(professions.values()),flush=True)

def parse():
    d=json.loads((T/'discovery.json').read_text());enchant={}
    for i in d['itemIDs']:
        if d['professions'].get(str(i))=='enchanting':
            for sid in re.findall(r'href="/spell=(\d+)',cached('item',i).get('tooltip','')):
                if int(sid) in d['spellIDs']:enchant[int(sid)]=i
    rows=[]
    for sid in d['spellIDs']:
        spell=cached('spell',sid);raw=spell.get('tooltip','')
        reagents=re.search(r'Reagents:.*?<div[^>]*>(.*?)</div>',raw)
        if not reagents:continue
        inputs=[dict(itemID=int(i),name=plain(n),quantity=int(q or 1)) for i,n,q in re.findall(r'<a href="/item=(\d+)[^"]*">(.*?)</a>(?:&nbsp;)?(?:\s*\((\d+)\))?',reagents[1])]
        out=re.search(r'<span class="q\d"><a href="/item=(\d+)[^"]*">.*?</a></span>(?:\s*\((\d+)\))?',raw)
        item_id=int(out[1]) if out else enchant.get(sid) or d['spellOutputs'].get(str(sid))
        if not item_id or str(item_id) not in d['professions'] or not inputs:continue
        source=raw[reagents.end():out.start()] if out else raw[reagents.end():]
        source_match=re.search(r'(?:Vendor:|Profession Trainer:|Profession:|Drop:|Quest:|Discovery:|Fishing:|Specialization:).*',plain(source))
        name=cached('item',item_id).get('name',spell.get('name'))
        if re.search(r'Fleeting|Conjured|zzOld|DNT',name or ''):continue
        if d['professions'][str(item_id)] in ('mining','herbalism'):continue
        rows.append(dict(spellID=sid,itemID=item_id,name=name,profession=d['professions'][str(item_id)],outputQuantity=int(out[2] or 1) if out else 1,reagents=inputs,source=source_match[0] if source_match else 'Learn the corresponding Midnight recipe; check profession and specialization requirements.',bound=bound(item_id),removed=item_id in d['removedIDs'],future=item_id in d['futureIDs'],housing=item_id in d['housingIDs'],cooldown=bool(re.search('cooldown',plain(raw))),variableOutput=bool(re.search(r'Chance to create multiple|Produces \d+, plus additional',plain(raw))),sourceUrl=f'https://www.wowhead.com/spell={sid}',unmodeledRequiredSlots=bool(re.search(r'currency=|items\?filter',reagents[1]))))
    save('candidate-recipes.json',rows)
    print('Parsed',len(rows),'recipes',Counter(r['profession'] for r in rows),flush=True)
    inputs={x['itemID'] for r in rows for x in r['reagents']}
    many([('item',i) for i in inputs if not cached('item',i)])

def effects():
    rows=json.loads((T/'candidate-recipes.json').read_text(encoding='utf-8'))
    spells=sorted({r['spellID'] for r in rows})
    def one(sid):
        path=T/f'effect-{sid}.json'
        if path.exists():return sid,json.loads(path.read_text())
        try:
            raw=download(f'https://wago.tools/db2/SpellEffect/csv?filter%5BSpellID%5D={sid}',f'effect-{sid}.csv')
            value=list(csv.DictReader(io.StringIO(raw)))
            path.write_text(json.dumps(value),encoding='utf-8');return sid,value
        except Exception as e:return sid,{'error':str(e)}
    errors=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for index,(sid,value) in enumerate(pool.map(one,spells),1):
            if isinstance(value,dict):errors.append([sid,value])
            if index%100==0:print('Batch effects',index,'/',len(spells),flush=True)
    save('effect-errors.json',errors);print('Effect errors',len(errors),flush=True)
    for name in ['CraftingData','CraftingDataItemQuality','CraftingDataEnchantQuality']:
        print(name,len(download(f'https://wago.tools/db2/{name}/csv',name+'.csv')),flush=True)

def sources():
    sources=json.loads((T/'sources.json').read_text())
    for profession in ['alchemy','blacksmithing','enchanting','engineering','inscription','jewelcrafting','leatherworking','tailoring']:
        sources[profession+'-guide.html']=f'https://www.wow-professions.com/midnight/{profession}-guide'
    sources.update({
        'fishing-guide.html':'https://www.wow-professions.com/guides/wow-fishing-leveling-guide',
        'skinning-guide.html':'https://www.method.gg/guides/midnight-skinning-profession-guide',
        'species-guide.html':'https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine',
        'majestic-guide.html':'https://www.method.gg/guides/midnight-majestic-beast-lure-locations',
        'cloth-guide.html':'https://www.method.gg/guides/best-bright-linen-cloth-farming-locations',
        'patch-12-1.html':'https://www.wow-professions.com/news/midnight-patch-12-1-knowledge-point-reset',
        'venom-guide.html':'https://www.method.gg/guides/farming-routes-for-neutralized-venom-clot-and-cursebound-globes-in-wow-midnight',
    })
    def get(nv):
        name,url=nv
        try:return name,len(download(url,name))
        except Exception as e:return name,str(e)
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for result in pool.map(get,sources.items()):print(*result,flush=True)
    save('sources.json',sources)
    ids={int(i) for name in sources for i in re.findall(r'(?:item=|item%3D)(\d+)',(T/name).read_text(encoding='utf-8')) if (T/name).exists()}
    existing=(R/'Data/FarmingItems.lua').read_text(encoding='utf-8')
    ids.update(int(i) for i in re.findall(r'itemID = (\d+),[^\n]+expansion = "midnight"',existing))
    many([('item',i) for i in ids if not cached('item',i)])
    save('guide-item-ids.json',sorted(ids))

def extra_pages():
    d=json.loads((T/'discovery.json').read_text())
    modeled={r['itemID'] for r in json.loads((T/'candidate-recipes.json').read_text(encoding='utf-8'))}
    ids={i for i in d['itemIDs'] if i not in modeled and d['professions'][str(i)] not in ['herbalism','mining'] and not bound(i) and not re.search('Fleeting|Conjured|zzOld|DNT',cached('item',i).get('name',''))}
    ids.update(json.loads((T/'guide-item-ids.json').read_text()))
    ids={i for i in ids if cached('item',i).get('name') and not bound(i)}
    def get(i):
        try:return i,len(download(f'https://www.wowhead.com/item={i}',f'page-item-{i}.html'))
        except Exception as e:return i,str(e)
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:results=list(pool.map(get,sorted(ids)))
    save('page-status.json',results)
    created=[];comments={}
    for i in ids:
        path=T/f'page-item-{i}.html'
        if not path.exists():continue
        text=path.read_text(encoding='utf-8')
        start=text.find("id: 'created-by-spell'")
        if start>=0:
            block=text[start:text.find('});',start)];start=block.find('data:')
            if start>=0:
                for row in json.JSONDecoder().raw_decode(block[start+5:].lstrip())[0]:
                    if row.get('reagents') and row.get('creates'):created.append(dict(itemID=i,record=row,sourceUrl=f'https://www.wowhead.com/item={i}'))
        match=re.search(r'var lv_comments\d*\s*=\s*',text)
        if match:comments[i]=json.JSONDecoder().raw_decode(text[match.end():])[0]
    save('page-created-by.json',created);save('comments.json',comments)
    print('Item pages',len(ids),'failures',sum(isinstance(r[1],str) for r in results),'created-by rows',len(created),'comments',sum(map(len,comments.values())),flush=True)
    many([('spell',r['record']['id']) for r in created if not cached('spell',r['record']['id'])])

def select():
    d=json.loads((T/'discovery.json').read_text());rows=json.loads((T/'candidate-recipes.json').read_text(encoding='utf-8'))
    quality=defaultdict(set)
    for name in ['CraftingDataItemQuality','CraftingDataEnchantQuality']:
        for entry in csv.DictReader((T/(name+'.csv')).open()):quality[int(entry['CraftingDataID'])].add(int(entry['ItemID']))
    data={int(entry['ID']):entry for entry in csv.DictReader((T/'CraftingData.csv').open())}
    groups=defaultdict(list);bad=[]
    for r in rows:
        path=T/f'effect-{r["spellID"]}.json'
        if not path.exists():bad.append(r);continue
        found=[]
        for e in json.loads(path.read_text()):
            if e['Effect']=='24':family={int(e['EffectItemType'])}
            elif e['Effect'] in ['288','301']:
                cid=int(e['EffectMiscValue_0']);family=quality[cid]|{int(data.get(cid,{}).get('CraftedItemID',0))}
            else:continue
            if r['itemID'] in family:found.append((e,family))
        if not found:bad.append(r);continue
        e,family=found[0]
        for i in family:
            if i not in d['itemIDs'] or cached('item',i).get('name')!=r['name']:continue
            v=dict(r);v.update(itemID=i,bound=bound(i),outputQuantity=max(1,int(float(e['EffectBasePointsF']))),qualityFamily=sorted(family),effectType=e['Effect'],batchSourceUrl=f'https://wago.tools/db2/SpellEffect?filter[SpellID]={r["spellID"]}')
            rank=re.search(r'(\+{1,3})$',d['names'].get(str(i),''))
            if rank:v['qualityRank']=len(rank[1])
            raw=cached('spell',v['spellID']).get('tooltip','')
            for key,marker in [('cooldownDescription','cooldownText'),('chargesDescription','chargesText')]:
                match=re.search(f'<!--{marker}-->(.*?)<!--{marker}-->',raw)
                if match:v[key]=plain(match[1]);v['cooldown']=True
            groups[i].append(v)
    canonical={i:sorted(rs,key=lambda r:(r['unmodeledRequiredSlots'],r['cooldown'],r['spellID']))[0] for i,rs in groups.items()}
    inputs={x['itemID'] for r in canonical.values() for x in r['reagents']}
    vendor={38682,244174} # Plain starter enchanting rod is vendor-only; the runed rod is crafted.
    for i in inputs:
        text=plain(cached('item',i).get('tooltip',''))
        if re.search(r'Sold by .*vendors|Sold by vendors|purchased from (?:tradeskill )?vendors|Acquired by purchase from',text,re.I) and i not in canonical:
            vendor.add(i)
    # Sunglass Vials have a verified Jewelcrafting recipe as well as a vendor source.
    vendor.discard(240991)
    heraldry_block=re.search(r'^    \[256559\] = \{(.*?)^    \},',(T/'reagents-db.lua').read_text(encoding='utf-8'),re.M|re.S)[1]
    heraldry={int(s):(int(i),int(q)) for s,i,q in re.findall(r'\[(\d+)\] = \{(\d+), (\d+)\}',heraldry_block)}
    for r in canonical.values():
        if not r['unmodeledRequiredSlots']:continue
        raw=cached('spell',r['spellID']).get('tooltip','')
        block=re.search(r'Reagents:.*?<div[^>]*>(.*?)</div>',raw)[1]
        slots=re.findall(r'<a href="/items\?filter=243;(\d+);0">([^<]+)</a>(?:&nbsp;)?(?:\s*\((\d+)\))?',block)
        if len(slots)==1 and slots[0][0]=='471' and r['spellID'] in heraldry:
            expected_id,quantity=heraldry[r['spellID']]
            assert expected_id in r['qualityFamily']
            # Current recipe tooltip quantities take precedence over a stale reagent index.
            r['requiredReagentSlots']=[dict(categoryID=471,selectedItemID=256559,quantity=int(slots[0][2] or 1))]
            r['unmodeledRequiredSlots']=False
    selected={i:r for i,r in canonical.items() if not r['bound'] and not r['removed'] and not r['future'] and not r['unmodeledRequiredSlots']}
    changed=True
    while changed:
        changed=False
        for r in list(selected.values()):
            for x in r['reagents']:
                i=x['itemID']
                if i in canonical and i not in selected and i not in vendor and not canonical[i]['unmodeledRequiredSlots']:
                    selected[i]=canonical[i];changed=True
    for r in selected.values():
        r['components']=[dict(itemID=x['itemID'],quantity=x['quantity']) for x in r['reagents'] if x['itemID'] not in vendor]
        r['components'] += [dict(itemID=x['selectedItemID'],quantity=x['quantity']) for x in r.get('requiredReagentSlots',[])]
        r['omittedVendorReagents']=[dict(x) for x in r['reagents'] if x['itemID'] in vendor]
    selected={i:r for i,r in selected.items() if r['components']}
    save('selected-recipes.json',list(selected.values()));save('excluded-vendor.json',sorted(vendor));save('unverified-recipes.json',bad)
    known={int(i) for i in re.findall(r'itemID = (\d+),',(R/'Data/FarmingItems.lua').read_text(encoding='utf-8'))}
    unknown={x['itemID'] for r in selected.values() for x in r['components']}-set(selected)-known
    save('unknown-inputs.json',sorted(unknown))
    missing=[i for i in d['itemIDs'] if i not in selected and not bound(i) and d['professions'][str(i)] not in ['herbalism','mining'] and not re.search('Fleeting|Conjured|zzOld|DNT',cached('item',i).get('name',''))]
    save('unmodeled-items.json',missing)
    print('Selected',len(selected),'recipes;',sum(r['housing'] for r in selected.values()),'housing;',sum(r['bound'] for r in selected.values()),'bound support;',Counter(r['profession'] for r in selected.values()),flush=True)
    print('VENDOR',[(i,cached('item',i).get('name')) for i in sorted(vendor)],flush=True)
    print('UNKNOWN INPUTS',[(i,cached('item',i).get('name'),bound(i)) for i in sorted(unknown)],flush=True)
    print('Unverified recipe identities',len(bad),'required-slot recipes',sum(r['unmodeledRequiredSlots'] for r in canonical.values()),'unmodeled',len(missing),flush=True)

def augment():
    d=json.loads((T/'discovery.json').read_text())
    spells=set(d['spellIDs'])
    for path in T.glob('*guide.html'):
        spells.update(int(i) for i in re.findall(r'(?:spell=|spell%3D)(\d+)',path.read_text(encoding='utf-8')))
    for i in d['itemIDs']:
        v=cached('item',i)
        if re.match(r'Recipe:|Design:|Schematic:|Pattern:|Technique:|Plans:',v.get('name','')) or 'Combine the Ace through Eight' in v.get('tooltip',''):
            spells.update(int(sid) for sid in re.findall(r'href="/spell=(\d+)',v.get('tooltip','')))
    for path in [T/'patch-12-1.html']:
        spells.update(int(i) for i in re.findall(r'(?:spell=|spell%3D)(\d+)',path.read_text(encoding='utf-8')))
    spells.update(r['record']['id'] for r in json.loads((T/'page-created-by.json').read_text(encoding='utf-8')))
    print('Supplementary spell lookups',len(spells-set(d['spellIDs'])),flush=True)
    many([('spell',sid) for sid in sorted(spells) if not cached('spell',sid)])
    d['spellIDs']=sorted(spells);save('discovery.json',d)

def resolve_names():
    d=json.loads((T/'discovery.json').read_text());selected={r['itemID'] for r in json.loads((T/'selected-recipes.json').read_text(encoding='utf-8'))}
    names={cached('item',i).get('name') for i in d['itemIDs'] if i not in selected and not bound(i) and i not in d['futureIDs'] and d['professions'][str(i)] not in ['herbalism','mining','skinning','fishing']}
    names={n for n in names if n and not re.search(r'Fleeting|Conjured|zzOld|DNT',n)}
    def one(name):
        slug=re.sub('[^a-zA-Z0-9]+','-',name)
        try:
            value=download('https://wago.tools/db2/SpellName/csv?'+urllib.parse.urlencode({'filter[Name_lang]':name}),'spellname-'+slug+'.csv')
            return [int(row['ID']) for row in csv.DictReader(io.StringIO(value)) if row['Name_lang']==name]
        except Exception as e:return []
    found=set()
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for ids in pool.map(one,sorted(names)):found.update(ids)
    found-=set(d['spellIDs'])
    print('Resolved',len(names),'missing output names to',len(found),'extra spell IDs',flush=True)
    many([('spell',sid) for sid in sorted(found)])
    d['spellIDs']=sorted(set(d['spellIDs'])|found);save('discovery.json',d)

if __name__=='__main__':
    stage=sys.argv[1]
    if stage=='discover':discover()
    elif stage=='fetch':
        d=json.loads((T/'discovery.json').read_text());many([('item',i) for i in d['itemIDs']]+[('spell',s) for s in d['spellIDs']])
    elif stage=='parse':parse()
    elif stage=='effects':effects()
    elif stage=='sources':sources()
    elif stage=='extra-pages':extra_pages()
    elif stage=='select':select()
    elif stage=='augment':augment()
    elif stage=='resolve-names':resolve_names()
