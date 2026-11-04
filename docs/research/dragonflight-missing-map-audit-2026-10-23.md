# Dragonflight Materials: missing Map data

Scope: visible Dragonflight Materials, including Raid Items and excluding all
Composed Materials. Existing recipes, component graphs, and working gathering
maps are preserved.

## Result

The real Materials row builder exposes **148 non-composed items**, including
**two Raid Items**. Before this pass, **44 lacked Map buttons**. Another **14**
prospecting entries exposed a map flag but could not open: a shared legacy
coordinate array mixed two zones without map IDs.

All 148 visible items now open maps. This pass enriches 58 records with **421
map choices**, including input-route choices inherited from existing research.
These are not 421 newly surveyed farms. The **1,182 composed entries** remain
unchanged; the catalog item list and every material outside the 58 targets also
remain unchanged. Only 44 flags change in the lightweight MaterialIndex.

| Missing family | Items | Map behavior |
| --- | ---: | --- |
| Uncut gem quality variants | 22 | Existing Serevite/Draconium routes, then Jewelcrafting Prospecting |
| Pigments | 12 | Correct herb family routes, then Milling |
| Silken Gemdust ranks | 3 | Ore gathering, Prospecting, then gem Crushing |
| Rousing Order, Ire, Decay | 3 | Modifier-aware gathering paths or sourced decay search areas |
| Fire-Infused Hide | 1 | Skinning source-area navigation and listed fishing alternatives |
| Glowing Titan Orb | 1 | Tyrhold and Zaralek source-area navigation |
| Raid reagents | 2 | Sourced outdoor entrances and raid reward/lockout guidance |

## Acquisition and location evidence

- [Dragon Isles Prospecting](https://www.wowhead.com/spell=374627/dragon-isles-prospecting)
  consumes five ores and has random gem/byproduct outputs. The new quality-variant
  maps retain existing ore routes and their provenance. Input quality and
  Jewelcrafting setup affect the result; no named gem or rank is guaranteed.
- [Pigment-to-herb research](https://www.method.gg/guides/what-dragonflight-herbs-do-you-need-to-mill-to-get-each-pigment)
  maps Shimmering to Hochenblume, Blazing to Saxifrage, Serene to Bubble Poppy,
  and Flourishing to Writhebark. All three ranks use their matching herb family's
  existing paths with explicit Milling instructions.
- [Dragon Isles Crushing](https://www.wowhead.com/spell=395696/dragon-isles-crushing)
  consumes three eligible gems to make Silken Gemdust. The dust maps explain both
  processing steps after ore gathering; dust is not presented as a direct ore drop.
- [Rousing Order research](https://www.wowhead.com/guide/professions/farming-awakened-and-rousing-order)
  supports searching gathering paths for Titan-Touched nodes. The routes do not
  guarantee modifier locations or extra Order from Overload.
- [Infurious Serevite](https://www.wowhead.com/spell=389464/infurious-serevite-deposit)
  and the [Ire acquisition guide](https://diamondlobby.com/world-of-warcraft/how-to-get-rousing-ire-wow-dragonflight/)
  support War Mode/Infurious gathering. The guide also identifies PvP reward and
  War Supply Chest alternatives. The UI states the War Mode requirement and
  exposure to player combat; there are no guaranteed modified-node pins.
- [Rousing Decay reports](https://www.wowhead.com/item=190330/rousing-decay)
  identify the 18,34 Oozing Decay camp and 14,21 Creektooth search area. These are
  explicitly player-reported markers. [Blackenhide farming](https://www.wow-professions.com/farming/rousing-decay-farming)
  and [Decayed-herb research](https://www.wowhead.com/guide/professions/herbalism/overview-leveling-dragonflight)
  supply broader source-area alternatives. Historical respawn, rate and income
  claims are not copied as current guarantees.
- [Fire-Infused Hide](https://www.wowhead.com/item=193258/fire-infused-hide)
  establishes fiery-creature Skinning and lists fishing in Waking Shores,
  Zaralek and Emerald Dream. No fixed skinning pin or particular beast was
  established by the readable evidence, so the unsupported old Magmammoth
  assertion is replaced with the verified source family. Fishing alternatives
  remain zone-level side catches.
- [Glowing Titan Orb's acquisition table](https://www.wowhead.com/item=201406/glowing-titan-orb)
  supports Tyrhold titan constructs and named Zaralek containment enemies.
  Both options use source-area maps without fabricated spawn pins or historical
  quest-item tricks.
- [Raid reward research](https://gaminghero.io/wow-gold-making-in-raids/)
  and [Smolderon's loot table](https://www.wowhead.com/npc=200927/smolderon/heroic-encounter-journal)
  identify Dreaming Essence in Amirdrassil. The [Amirdrassil entrance guide](https://blizzardwatch.com/2023/11/13/amirdrassil-raid-entrance/)
  places the outdoor entrance at **27.30,31.04** on Emerald Dream map **2200**.
- [Shadowflame Essence drop reports](https://www.wowhead.com/item=204464/shadowflame-essence)
  identify Aberrus, including LFR, and an Amirdrassil alternative. The
  [Aberrus entrance guide](https://dotesports.com/wow/news/how-to-get-to-aberrus-the-shadowed-crucible-in-wow-dragonflight)
  places its entrance at **48.46,10.35** on Zaralek map **2133**. Both raid
  entrances are offered, with loot-eligibility and lockout qualifications.

The 14 legacy prospecting records cover the original gem ranks, Fractured Glass,
Crumbled Stone and Prismatic Ore. Their source module explicitly labels the
first seven points as Waking Shores and the next five as Ohn'ahran Plains.
Splitting these into map **2022** and **2023** options preserves all 168 point
instances and their order, source URLs and tips. Neither portion is presented
as a connected cross-zone route or a fixed output spawn.

## Artifacts and validation

- [Per-item source index](dragonflight-missing-map-source-index-2026-10-23.json)
  records all 58 targets, original map flags, evidence keys, inherited route
  identities, and evidence-review limits.
- [Coverage report](dragonflight-missing-map-coverage-2026-10-23.json) is generated
  through the actual Lua row, map-option, detail and map-opening functions. It
  opens all 148 visible maps, checks both Raid Items, exercises 60 search/filter
  cases, and builds 11,043 detail lines for the 421 enriched choices. Sources,
  tips and acquisition actions remain available in every enriched option.
- Six focused Dragonflight Lua checks pass, including exact preservation of the
  whole item catalog, every composed graph, other materials, original input
  geometry/provenance, repaired coordinate order and repeated-load stability.
  Existing BfA and Shadowlands map suites also pass: four checks each.
- Normal and expanded Materials views share the validated display rows.
  Manifest validation passes with seven manifests and 257 runtime Lua files;
  all runtime Lua files pass Lua 5.1 syntax validation.

Reproduce the coverage report from the repository root with Python and `lupa`:

```text
python tools/audit_bfa_material_maps.py --expansion dragonflight --output docs/research/dragonflight-missing-map-coverage-2026-10-23.json
```

The new module loads after CatalogGathering and the other expansion map
enrichments. Existing herb/ore routes, their coordinate ordering, exports,
source links and tips are inherited; they were not re-surveyed. New acquisition
evidence was checked by material family, without re-fetching every quality
variant's item page. The source index distinguishes readable opened pages from
readable search-index excerpts. An unreadable Dreaming Essence item page was
not treated as new evidence; the readable raid/boss sources above establish its
source instead. No private-server claims, live yields, sale prices, respawn
guarantees or new deterministic compositions are used.

Static and headless validation does not establish live WoW rendering or farming
results. `/reload` and in-game Materials/Map inspection remain unperformed.
