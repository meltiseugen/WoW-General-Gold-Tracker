# The War Within Materials: missing Map data

Scope: visible, non-Composed The War Within Materials, including all six
Instance items. No composed recipe or component graph is changed.

## Result

The real Materials row builder exposes **154 items**. Before this pass, **56**
lacked Map buttons and **six** had buttons with no usable map options. All 154
now open maps, and every listed source option for these visible items opens.

The new module enriches **89 records**: 56 missing maps and 33 existing records
with unusable sources. Those 33 include the six completely unusable buttons,
three partial fishing/Tinderbox records, and 24 herb/ore quality variants whose
supplied routes worked while older single-zone alternatives were silently
discarded. Those gathering alternatives now have explicit map IDs. Their
coordinates, order, route exports and provenance are retained.

The 89 enriched records expose **389 map choices**, including retained working
routes and derived input paths. These are not 389 newly surveyed farms.
**925 composed entries remain unchanged.** The whole item catalog and all
research outside these 89 records are preserved. The lightweight MaterialIndex
changes exactly 56 `hasMap` flags and retains all 7,326 records.

| Missing family | Items | Map behavior |
| --- | ---: | --- |
| Pigments | 12 | Matching herb routes, then Khaz Algar Milling |
| Thread spools | 9 | Matching cloth farms, then Unraveling |
| Crushed Gemstones | 3 | Bismuth gathering, Prospecting, then Crushing with the additional Bismuth cost |
| Modified gathering reagents | 2 | Altered/Sporefused node searches on eligible herb paths |
| Blasphemite | 1 | Thaumaturgy input routes and Gleaming Transmutagen processing guidance |
| Meat and prepared Cooking products | 14 | Species source areas, fishing inputs, processing steps, or egg-input/recipe access |
| Engineering salvage and refurbished tinkers | 8 | Processing input paths, profession context, and sourced purchase alternatives |
| PvP reagents | 2 | Quartermaster access; explicit historical availability for Season 1 Heraldry |
| Instance reagents | 5 | Four missing delve-reagent maps plus Manaforged Instrument raid access |

## Acquisition and location decisions

- [Pigment research](https://www.method.gg/guides/the-war-within-herb-milling-and-pigment-guide)
  ties Nacreous to Mycobloom, Luredrop to Luredrop, Orbinid to Orbinid, and
  Blossom to Blessing Blossom. All ranks use their own input family. Khaz Algar
  Milling consumes ten herbs; the map describes processing rather than pigment
  spawns.
- [Algari Crushing](https://www.wowhead.com/spell=434020/algari-crushing)
  needs three eligible gems **and ten Bismuth**. The added maps describe the
  ore-to-gem-to-Crushed Gemstones chain. [Unraveling](https://www.wowhead.com/spell=446926/unraveling)
  uses five matching cloth; specialty cloth still needs the appropriate
  Tailoring specialization. No deterministic composed recipes are added.
- [Slum Shark Scrap](https://warcraft.wiki.gg/wiki/Slum_Shark_Scrap) is a
  secondary result of processing Kaheti Slum Sharks with Cooking. Its map uses
  existing fishing paths. [Cooking input research](https://www.method.gg/guides/best-meat-and-fish-for-producing-ingredients-in-the-war-within)
  supports the other meat/fish processing chains without importing historical
  yields. Bound Cursed Ghoulfish remains hidden and is used only as an input
  for Prepared Ghoulfish.
- [Protein Slurp's actual recipe](https://www.wowhead.com/spell=447871/protein-slurp)
  uses five Fine Egg Powder after learning it from Eight-Shaker Sallow. This
  replaces generic processing notes that incorrectly pointed at Fresh Fillet.
  Egg maps distinguish the explicitly numbered City of Threads recipe and
  input-vendor layers. Suspiciously Heavy Eggs support Yolk as a secondary
  output; Yesterday's Eggs are not offered as a Yolk input.
- Raw creature meats use named, documented sources without invented spawn
  pins: Dazzling Peafowl in Isle of Dorn, Harvest Hauler/Isolated Crawler in
  Azj-Kahet, and worm sources including the rare elite Disturbed Earthgorger
  in The Ringing Deeps. These are source-area choices, not measured mass-pull
  routes.
- [Pilfer Through Parts reports](https://www.wowhead.com/spell=447311/pilfer-through-parts)
  distinguish bolt inputs from components yielding the rarer mount parts.
  Bountiful Bolts and refurbished tinkers use Bismuth-to-parts processing
  guidance, including Scour Through Scrap for tinkers. The five rarer Pummeler
  parts have explicitly labeled profession-context and purchase options.
  [Paxton's updated position](https://www.wowhead.com/npc=223163/paxton-bombshell)
  is a player-reported post-11.1 correction at 59.76,78.43, not the obsolete
  63.8/64.0 position. No obsolete vendor Bolts option is added.
- [Forged Combatant's Heraldry](https://warcraft.wiki.gg/wiki/Forged_Combatant%27s_Heraldry)
  can no longer be earned from its Season 1 sources. Its map explicitly gives
  historical quartermaster context and directs users to existing tradeable
  stock instead of promising current rewards. Vicious Bloodstone retains its
  supported PvP/Honor acquisition guidance without fixed reward rates.
- [Blizzard's October 1, 2024 hotfix](https://www.bluetracker.gg/wow/topic/eu-en/531278-the-war-within-hotfixes-16-october/)
  lists all five delve specialty reagents in any delve's Heavy Trunks. The
  maps offer representative outdoor entrances across all four original zones,
  using [explicit map-number waypoints](https://www.wowhead.com/achievement=40437/delver-of-the-depths).
  No reagent is promised exclusively or reliably from a particular entrance.
  Profaned Tinderbox's independent Borgos exchange is retained. Its old
  Nightfall Sanctum interior Sturdy Chest point is replaced with outdoor
  entrance/reward guidance, and the removed Delver's Pouch of Reagents is not
  advertised as a current source.
- [Manaforge Omega entrance research](https://www.blizzspirit.com/warcraft/manaforge-omega-guide-de-poche-du-raid-de-the-war-within/)
  places its outdoor entrance at K'aresh 41.8,21.5. The selected reagent names
  Forgeweaver Araz as its source; the map distinguishes entrance navigation
  from the boss location and explains access and loot eligibility. Story Mode
  is not offered as a reagent farm.

## Fishing map repairs

The old Anglerseeker array mixed Ringing Deeps and Hallowfall, while Royal Ripple
mixed Hallowfall and Azj-Kahet. Each is split into correctly numbered maps with
the original points and their relative ordering intact. Working alternatives
for Spiked Sea Raven and Goldengill Trout are retained.

The rare-water template mixed three Azj-Kahet water points with Method's
**City of Threads 67.72,24.29** entrance point. Method explicitly names the city
layer, whereas a different entrance list omitted that distinction. The old
point is retained as `legacyCoords` for provenance and replaced for navigation
with the explicit **/way #2255 54.8 72.6** outdoor approach. That option is
labeled **access only**, separately from the water search points; it does not
claim a fishing pool at the entrance.

Awoken Coelacanth's unsupported shared Ringing Deeps/Hallowfall alternatives
are removed. Its supported Azj-Kahet open-water map retains the Whispers of the
Deep bait requirement. Existing water search coordinates are inherited player
reports, not newly confirmed fish spawns or guaranteed catch rates.

## Artifacts and validation

- [Source index](tww-missing-map-source-index-2026-10-23.json): all 89 targets,
  initial flags and usable counts, inherited source identities, input chains,
  and 30 evidence entries with review limits.
- [Coverage report](tww-missing-map-coverage-2026-10-23.json): the actual Lua row,
  map-opening, option and detail builders open all 154 visible maps and all six
  Instance items. It verifies every visible source is usable, exercises 91
  filter/search checks, and builds 9,524 detail lines for the enriched choices.
  Normal and expanded views share the validated display rows.
- Six focused data checks cover catalog/composed/non-target preservation,
  repeated-load stability, input families and geometry, fishing layers,
  processing requirements, exterior instance pins, and unpinned source areas.
- Existing TWW cleanup and Dragonflight map suites pass. The broader Materials
  suite retains its pre-existing Nagrand/Twilight Ridge versus Catalog/Warmaul
  ordering failure; no Materials UI code is changed by this pass.
- Manifest and Lua 5.1 syntax validation pass for seven manifests and 258 runtime
  Lua files. Only the 56 intended MaterialIndex availability flags change.

Reproduce coverage from the repository root with Python and `lupa`:

```text
python tools/audit_bfa_material_maps.py --expansion warWithin --output docs/research/tww-missing-map-coverage-2026-10-23.json
```

Source evidence was reviewed by family, not by individually fetching every
quality variant. Existing gathering routes, exports, sources and tips are
retained; they were not re-surveyed. Some item/recipe evidence is available as
readable search-index excerpts while direct pages reject access. The source
index distinguishes those cases and inherited evidence. No fixed yields,
respawn promises or current sale prices are encoded.

This is static and headless verification. Live WoW rendering, loot behavior and
`/reload` inspection remain unperformed.
