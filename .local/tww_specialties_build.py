import os, sys, json, re
from pathlib import Path
T = Path(os.environ['TEMP']) / 'ggt-tww-specialty'
sys.path.insert(0, str(T))
from tww_research import cached, bound, plain, save

raw = {}
guide = 'https://www.wowhead.com/guide/the-war-within/professions/'
def marker(id, mapID, mapName, location, x, y):
    return dict(id=id, mapID=mapID, mapName=mapName, location=location,
                routeType='material-search', isRoute=False,
                coords=[dict(x=x, y=y, label=location)])
def add(i, professions, category, summary, tips, sources=(), spots=(), **extra):
    item = cached('item', i)
    assert item.get('name') and item.get('tooltip'), i
    record = dict(itemID=i, name=item['name'], professions=professions, category=category,
                  auctionable=not bound(i), summary=summary, tips=tips,
                  sourceUrls=list(dict.fromkeys([f'https://www.wowhead.com/item={i}']+list(sources))),
                  spots=list(spots), acquisitionType=extra.pop('acquisitionType', 'specialty-farm'))
    record.update(extra)
    if not record['auctionable']: record['supportOnly'] = True
    raw[i] = record

bee = marker('tww-cinderwold-specialty-search',2248,'Isle of Dorn','Cinderwold bee search area',.700,.436)
add(218338,['skinning','leatherworking'],'Species Skin',
    'Species-specific skinning reagent from storm creatures, including storm-touched wolves on Isle of Dorn.',
    ['Skin storm creatures rather than expecting this from every leathery beast.',
     'Players report elite storm wolves between Cinderbrew Meadery and Rambleshire alongside the bee farm.',
     'Elite packs may require a group; specialization and skinning eligibility apply.'],
    [guide+'skinning-overview','https://www.wowhead.com/quest=83097/cinder-and-storm'],
    reuseFrom=212670, reuseSpotMatch='elite-wolf')
add(218339,['skinning','leatherworking'],'Species Skin',
    'Species-specific material skinned from cinderbees; use the Cinderwold bee packs.',
    ['A player reports cinderbees around 70.0, 43.6 on Isle of Dorn.',
     'Skin the larger bees; comments report small bees yielding scraps instead.',
     'The same area has storm wolves for Bottled Storm. Drop rates and competition vary.'],
    [guide+'skinning-overview','https://www.wowhead.com/item=218338/bottled-storm'],[bee])
add(219013,['skinning','leatherworking'],'Daily Skinning Reagent',
    'Rare fang obtained by skinning the elusive Slatefang summoned in The Rumbling Wastes.',
    ['A later comment corrects the post-11.1 Ringing Deeps lure position to about 59.0, 51.0; older 62-63 X coordinates refer to the previous map.',
     'Summoning requires the Supreme Beast Lure and 40 points in Trained Tracker. The lure is bound and is not an AH product.',
     'Reports require Khaz Algar Skinning and level 72 or higher to receive the fang.',
     'Comments describe a daily reward limit, with conflicting reports about alts; verify eligibility and reset before repeating. No unlimited yield is assumed.'],
    [guide+'skinning-overview'],
    [marker('tww-slatefang-updated-lure-search',2214,'The Ringing Deeps','The Rumbling Wastes, post-11.1 reported lure area',.590,.510)],
    acquisitionType='limited-skinning')

for i in [223512,225565,225566,225567,225568,225569,225911]:
    tips=['Dropped by eligible Khaz Algar creatures; consult the item drop list for the matching species.',
          'Cooking can salvage five matching meat items into Portioned Steak or Spiced Meat Stock; outputs vary by meat type and cooking skill.',
          'Compare selling raw meat against processing it; no fixed average salvage yield is encoded.']
    add(i,['cooking'],'Meat','Tradeable Khaz Algar meat used directly in cooking or salvaged into prepared ingredients.',
        tips,[f'https://www.wowhead.com/spell=445118',f'https://www.wowhead.com/spell=445119'],
        [bee] if i==225911 else [], acquisitionType='creature-drop')
add(225912,['cooking'],'Cooking Finishing Reagent',
    'Hot Honeycomb is a chance-based byproduct when cooking salvages Cinderbee Belly; players also report rare bee drops.',
    ['Farm Cinderbee Belly, then portion the meat or prepare stock for additional chances at Hot Honeycomb.',
     'The byproduct is not a guaranteed quantity per five bellies. Use it as a finishing reagent or sell it separately.'],
    ['https://www.wowhead.com/item=225911/cinderbee-belly'],[bee],randomOutput=True,
    acquisitionType='cooking-salvage-byproduct')

clam = marker('tww-undermine-clam-marina-search',2346,'Undermine','Blackwater Marina, reported fishing water north of the bridge',.642,.107)
for i in [235846,235845]:
    add(i,['fishing','cooking'],'Openable Clam' if i==235846 else 'Clam Meat',
        'Undermine Clams are fished in Undermine and opened for tradeable Undermine Clam Meat. Both unopened clams and meat can be sold.',
        ['A player reports fishing at Blackwater Marina around 64.2, 10.7.',
         'Comments report 1-3 meat per clam; this is a variable container yield, not a guaranteed three.',
         'Low fishing skill can produce substantial junk. No reported catch rate is treated as a current guarantee.',
         'Authentic Undermine Clam Chowder uses the meat; it is separate from the older Classic chowder.'],
        ['https://www.wowhead.com/item=235846/undermine-clam',guide+'fishing-overview'],[clam],
        acquisitionType='fishing' if i==235846 else 'container-loot',randomOutput=i==235845)

for ids,base in [([224828,228231,228232],228231),([224824,228233,228234],224824),([224826,228235,228236],224826)]:
    for rank,i in enumerate(ids,1):
        add(i,['tailoring'],'Cloth',
            'Tradeable Khaz Algar cloth from eligible humanoids; specialty Dawnweave and Duskweave drops require the corresponding Tailoring specialization.',
            ['Tailoring and the relevant specializations determine cloth eligibility and quality.',
             'The Opalcreg and Veneration Grounds markers are humanoid search areas, not guaranteed individual spawns.',
             'Unravel matching cloth in batches of five to make thread; thread quantity and quality are not fixed here.'],
            [guide+'tailoring-overview','https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within'],
            qualityRank=rank,reuseFrom=base)

for family,source in [(range(222789,222792),224824),(range(222792,222795),224826),(range(222795,222798),224828)]:
    for rank,i in enumerate(family,1):
        add(i,['tailoring'],'Processed Thread',
            'Tradeable thread obtained by unraveling the matching Khaz Algar cloth, used by composed Tailoring recipes.',
            ['Unravel five matching cloth items using Khaz Algar Tailoring.',
             'Source cloth, skill and specialization affect the output. There is no fixed named-quality thread recipe or invented average yield.',
             'Dawnthread and Duskthread require the corresponding specialty-cloth access.'],
            ['https://www.wowhead.com/spell=446926',f'https://www.wowhead.com/item={source}'],
            qualityRank=rank,randomOutput=True,acquisitionType='unraveling')

for family in [range(222612,222615),range(222618,222621),range(224800,224803),range(224803,224806)]:
    for rank,i in enumerate(family,1):
        add(i,['inscription'],'Pigment','Tradeable pigment produced by Khaz Algar Milling and used in composed ink and Inscription crafts.',
            ['Mill the appropriate Khaz Algar herbs. This is a processed pigment, not a new raw-herb farming entry.',
             'Pigment amounts and achieved quality vary; no deterministic per-pigment yield is encoded.'],
            [guide+'inscription-overview','https://www.wowhead.com/spell=444181'],qualityRank=rank,
            randomOutput=True,acquisitionType='milling')
for rank,i in enumerate([213219,213220,213221],1):
    add(i,['jewelcrafting'],'Crushed Gemstones','Tradeable Jewelcrafting reagent produced by crushing eligible Algari gems.',
        ['Use Algari Crushing on eligible gems. Quantity and quality depend on the chosen gem and profession setup.',
         'Compare selling the gem, cutting it or crushing it; no guaranteed fixed crushing return is modeled.'],
        [guide+'jewelcrafting-overview','https://www.wowhead.com/spell=434020'],
        qualityRank=rank,randomOutput=True,acquisitionType='gem-crushing')

for i in [222737,222738,222739,222741,223967,223977,225876,225883]:
    add(i,['cooking'],'Processed Cooking Ingredient',
        'Saleable result of Khaz Algar cooking salvage or preparation; the available material and skill determine the output.',
        ['Use the matching preparation recipe and eligible input. Salvage quantities vary, so this record has no fabricated fixed ingredient ratio.',
         'Portioned Steak and Spiced Meat Stock use five matching meats; Fresh Fillet uses fish and Chopped Mycobloom uses five Mycobloom.',
         'Fine Egg Powder and Coagulated Yolk come from processing purchased Azj-Kahet eggs; the raw vendor eggs are excluded. They are processed products, not outdoor farm drops.'] if i in [223977,225876] else
        ['Use the matching cooking preparation recipe on eligible ingredients. Output varies with skill and source material.',
         'These are processed products used by the composed food recipes, not additional raw herb or ore entries.'],
        [guide+'cooking-overview',f'https://www.wowhead.com/spell={445117 if i==222737 else 445118 if i==222738 else 445119 if i==222739 else 447869 if i in [223977,225876] else 445116}'],
        randomOutput=True,acquisitionType='cooking-processing')

for i in [212514,223487]:
    add(i,['alchemy'],'Thaumaturgy Reagent' if i==212514 else 'Alchemy Pet',
        'Tradeable Blasphemite gem from the Thaumaturgy/Gleaming Transmutagen system.' if i==212514 else
        'Saleable Writhing Transmutagen companion item associated with Alchemy transmutation; this is distinct from the bound transmutagen reagents.',
        ['Alchemy specialization and transmutation/thaumaturgy unlocks apply.',
         'Gleaming, Ominous, Mercurial and Volatile Transmutagen reagents bind on pickup and are not AH products.',
         'This is a chance-based processing source; no guaranteed input-to-output ratio or income is assigned.'],
        [guide+'alchemy-overview','https://www.wowhead.com/spell=430315'],randomOutput=True,
        acquisitionType='thaumaturgy')

add(215236,['jewelcrafting'],'PvP Reagent','Vicious Bloodstone is a tradeable PvP crafting reagent with rare reward sources as well as an Honor purchase option.',
    ['Item data describes rare battleground/arena acquisition; guides also list eligible War Supply Chests, bounties and PvP reward containers.',
     'Reward eligibility and season matter. Honor purchasing is an alternative, not the reason this item is retained.',
     'Do not confuse it with bound socket upgrades or assume a drop from every victory.'],
    ['https://warcraft.wiki.gg/wiki/Vicious_Bloodstone'],acquisitionType='pvp-reward')
add(210221,['blacksmithing','jewelcrafting','tailoring','leatherworking','engineering','inscription'],
    'PvP Crafting Reagent','Tradeable Forged Combatant\'s Heraldry comes from PvP activities as well as Honor purchases and fills the required heraldry slot in Algari Competitor crafts.',
    ['Current item acquisition text lists PvP activities, so this is not a vendor-only supply.',
     'The composed PvP recipes use this tradeable Season 1 heraldry as their recorded baseline choice; other accepted heraldry can have different binding, availability and effects.',
     'Legacy season and reward eligibility matter. No current PvP reward rate or sale value is assumed.'],
    ['https://www.wowhead.com/item=210221/forged-combatants-heraldry'],acquisitionType='pvp-reward')

for i in [213611,213612]:
    add(i,['alchemy','enchanting','leatherworking'],'Modified Gathering Byproduct',
        'Tradeable non-herb reagent used in the composed profession recipes; its acquisition is a modified gathering byproduct rather than a creature blood drop.',
        ['Writhing Sample comes from Altered herbs and Weeping ore; Viridescent Spores comes from eligible herbalism activities.',
         'These are secondary recipe ingredients. This pass adds no raw ore or herb farming entry and assigns no fixed gather yield.'],
        [guide+'alchemy-overview',guide+'herbalism-overview',guide+'mining-overview'],
        acquisitionType='gathering-byproduct')

for i in [221754,221756,221757,221763]:
    add(i,['leatherworking'] if i==221757 else ['alchemy','blacksmithing','enchanting','engineering'],
        'Delve Reagent','Tradeable specialty reagent obtained through eligible delve rewards and containers; older guides assigned each reagent to particular delves.',
        ['Check eligible delve Heavy Trunks, reward chests and Brann gathering opportunities. Sources and access have changed since launch.',
         'Gloomfathom Hide is a delve/drop reagent, not a normal skinning hide.',
         'An item may also have an exchange/vendor source; that does not make its supported reward source vendor-only.',
         'Disturbed Earth reports for Gloomfathom Hide conflict after patches; do not assume the old dirt-pile trick still works.'],
        ['https://www.wowhead.com/item=221757/gloomfathom-hide',guide+'leatherworking-overview'],
        acquisitionType='delve-container')

add(249218,['inscription','enchanting'],'Raid Reagent','Saleable reagent rarely obtained from Forgeweaver Araz in Manaforge Omega; used by composed crafts including new illusions and Cartel deals.',
    ['The current item tooltip names Forgeweaver Araz as the source; players also report LFR drops.',
     'Raid access, loot eligibility and lockouts apply. No repeatable outdoor farm or fixed drop probability is assumed.'],
    ['https://www.wowhead.com/guide/the-war-within/raids/manaforge-omega/forgeweaver-araz'],
    acquisitionType='instance',instances=['Manaforge Omega'])

for i in [227769,227770,227771,227772,227773,227774,225241,225242]:
    add(i,['engineering'],'Salvaged Engineering Part' if i<225000 or i>=227000 else 'Salvaged Tinker',
        'Tradeable Khaz Algar engineering salvage or pilfering product; expensive Pummeler parts also have vendor sources.',
        ['Pilfer Through Parts destroys five eligible old or new engineering components for random scrap and part opportunities.',
         'Pummeler parts require the relevant Parts specialization; reports on Pummel Permit are extremely variable and do not establish a guaranteed yield.',
         'Scour Through Scrap and Inventing supply engineering discoveries and prototypes; refurbished tinkers are processing finds.',
         'Compare buying the finished part with processing inputs. No fixed pilfering ratio or profit is encoded.'],
        [guide+'engineering-overview','https://www.wowhead.com/spell=447311','https://www.wowhead.com/spell=447310'],
        randomOutput=True,acquisitionType='engineering-salvage')
add(219150,['engineering'],'Bound Craft Input','Bound Pile of Rusted Scrap is required by some saleable engineering products; the scrap itself cannot be auctioned.',
    ['Obtain through eligible engineering activities and pilfering. Scour Through Scrap consumes batches of five.',
     'This is a support ingredient, not an AH farming recommendation.'],
    [guide+'engineering-overview','https://www.wowhead.com/spell=447311'],acquisitionType='engineering-salvage')
add(248012,['miscellaneous'],'Bound Housing Input','Dornic Fir Lumber is harvested in Khaz Algar and K\'aresh for housing crafts. It binds to the Warband and cannot be sold on the AH.',
    ['Unlock lumber harvesting through the housing introduction and harvest eligible trees.',
     'Tree locations are dynamic; no permanent spawn coordinates are fabricated.',
     'Use the lumber in saleable finished decor. The lumber itself is a bound support input.'],
    ['https://www.wowhead.com/guide/player-housing/crafting-decor-items'],acquisitionType='lumber-harvest')

for i in list(range(222654,222662))+list(range(222663,222671))+list(range(222672,222680))+list(range(222681,222689)):
    add(i,['inscription','tailoring'],'Darkmoon Card','Tradeable named Khaz Algar Darkmoon card. Assemble the matching eight cards into the corresponding composed deck.',
        ['Cards have chance-based crafting and Tailoring cloth-farm sources; specialization and unlocks matter.',
         'There is no deterministic recipe for one specified named card. Buy or collect the full matching set before assembling a deck.'],
        [guide+'inscription-overview',guide+'tailoring-overview','https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within'],
        randomOutput=True,acquisitionType='random-card')

for i in list(range(225752,225763))+[225884]:
    path=T/f'page-item-{i}.html'
    if not path.exists() or "id: 'fished-in'" not in path.read_text(encoding='utf-8') or bound(i):continue
    add(i,['fishing'],'Fishing Appearance','Tradeable unused Khaz Algar fishing appearance item. Its item acquisition table lists fishing sources.',
        ['Fish in the Khaz Algar waters listed on the item page. The cosmetic is a chance-based catch.',
         'Equipping or learning the appearance can bind it; sell the unused item.',
         'This is a transmog market item, with no assumed sale rate or catch probability.'],
        [guide+'fishing-overview'],acquisitionType='fishing')

# Fill the missing current Refulgent Crystal rank and correct rank metadata.
for rank,i in enumerate([219952,219954,219955],1):
    add(i,['enchanting'],'Enchanting','Refulgent Crystal comes from disenchanting eligible epic Khaz Algar equipment; quality depends on the profession setup.',
        ['The map markers are gear-feed search areas, not outdoor crystal spawns.',
         'Use the current rank IDs 219952, 219954 and 219955.'],
        [guide+'enchanting-overview'],qualityRank=rank,reuseFrom=219952,acquisitionType='disenchanting')

# Random processes remain standalone source records; deterministic compositions stay separate.
recipes=json.loads((T/'selected-recipes.json').read_text(encoding='utf-8'))
selected={r['itemID'] for r in recipes}
raw=[v for i,v in sorted(raw.items()) if i not in selected]
save('selected-specialties.json',raw)
print('Specialty records',len(raw),'bound support',sum(not r['auctionable'] for r in raw))
known={int(i) for i in re.findall(r'itemID = (\d+),',Path('Data/FarmingItems.lua').read_text(encoding='utf-8'))}|selected|{r['itemID'] for r in raw}
missing={x['itemID'] for r in recipes for x in r['components']}-known
assert not missing,missing
