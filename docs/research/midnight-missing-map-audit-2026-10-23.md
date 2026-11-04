# Midnight Materials: missing Map data

Scope: visible non-Composed Midnight Materials, including Instance items.
The earlier fishing-cosmetic migration remains intact.

## Result

All **131 visible materials** now open every listed map option. This pass fills
**54 missing Map buttons** with **281 source choices**. Those choices include
existing gathering paths reused as processing inputs; they are not 281 newly
surveyed farms. No existing map needed repair.

All **seven Instance items** already had working maps and are explicitly checked
by the coverage audit: both qualities of Bright Linen, Sunfire Silk and
Arcanoweave, plus Petrified Root. Their maps and source data are preserved.
**773 composed entries remain unchanged.** The entire item catalog and all
research outside the 54 targets also remain unchanged. Regenerating MaterialIndex
changes exactly 54 availability flags and retains all **7,311 records**.

| Missing family | Items | Map behavior |
| --- | ---: | --- |
| Pigments | 4 | Matching herb paths, then ten-herb Milling |
| Prospecting gems/byproduct | 6 | Appropriate ore input paths and bonus/specialization guidance |
| Glimmering Gemdust | 1 | Ore gathering, Prospecting, then Crushing three gems plus one Stone |
| Aetherlume/Evercore | 4 | Distinct crafting/Milling inputs, then Engineering Recycling |
| Coiled Isle fish | 14 | Named pool source areas, lure/progression notes, one reported fishing point |
| Fishing novelties/lures | 5 | Eligible fishing regions; Ambiguous Rock precursor conversion distinguished |
| Shredded fishing-line fragments | 2 | Base catch regions; higher-tier combinations remain separate |
| Thalassian Fillet | 1 | Existing fish paths, then current one-fish Cooking processing |
| Fishing recipe drops | 13 | Treasure-pool search areas and random bottle contents |
| PvP reagents | 2 | Silvermoon quartermaster access, including explicitly legacy Heraldry context |
| Coiled Isle gathering byproducts | 2 | Curse Surge window and modifier-specific gathering guidance |

## Acquisition decisions and evidence

- [Midnight Milling](https://www.wowhead.com/spell=1269575/midnight-milling)
  consumes ten matching herbs. [Method's input table](https://www.method.gg/guides/midnight-inscription-profession-guide)
  maps Tranquility Bloom to Powder Pigment, Argentleaf to Argentleaf Pigment,
  Mana Lily to Mana Lily Pigment, and Sanguithorn to Sanguithorn Pigment.
  Azeroot is not substituted as a generic pigment input.
- [Midnight Prospecting](https://www.wowhead.com/spell=1231127/midnight-prospecting)
  consumes five matching ores. [Ore-specific gem guidance](https://www.method.gg/guides/midnight-jewelcrafting-profession-guide)
  distinguishes Umbral Tin's Peridot/Amethyst family from Brilliant Silver's
  Garnet/Lapis family. Dazzling Thorium is a gathering bonus rather than a
  dedicated deposit; its Diamond path is separate from specialization-enabled
  chances on other ores.
- [Midnight Crushing](https://www.wowhead.com/spell=1231132/midnight-crushing)
  consumes **three gems plus one Dusk-Shrouded Stone**. Glimmering Gemdust is
  presented as the crushing output after gathering/prospecting, never as a
  direct ore or prospecting drop.
- [Recycling input guidance](https://www.wow-professions.com/midnight/engineering-guide)
  distinguishes Powder Pigment into Evercore from Soul Sprockets into Aetherlume.
  The latter map explicitly discloses purchased Malleable Wireframe as an extra
  craft requirement. Basic and Imbued Bright Linen Bolts are not treated as
  interchangeable recycling inputs. No fixed conversion yield is encoded.
- The freshly retrieved live [Thalassian Fillet spell](https://www.wowhead.com/spell=1259655/thalassian-fillet)
  consumes **one fish**. An older wiki description still says five; that stale
  batch size is not used. Cooking output still depends on skill and fish rarity.
- [Coiled Isle fishing reports](https://www.wowhead.com/achievement=63629/angler-of-the-coiled-isle)
  provide the individual pool targets and the Spotted Killifish report at
  **/way #2512 51.5 53.7**. Rotating pool locations remain unpinned source areas.
  Coiled Stargorger requires a lure-created Torrential Gorgerswarm; its
  [lure/recipe guidance](https://www.wowhead.com/item=241151/coiled-stargorger-lure)
  supplies the separate Second Mate Sluggs access marker at **51.6,49.8**.
  That point is labeled recipe access, not a fish spawn. Blightswarmer notes
  disclose the reported Shell of Yourself progression and Curse Surge buff.
  Ula'tek Snakehead notes distinguish lure-free pool catches from reported
  lure-enabled open-water fishing.
- [Ambiguous Rock](https://www.wowhead.com/item=266102/ambiguous-rock) is the
  inspectable result of precursor **238490**, with a reported five-minute
  transformation. Its map locates the fishing region; it does not claim a
  direct catch of 266102 or use Definitely Not a Rock as its required precursor.
  Existing novelty and consumable-lure classifications are retained.
- [Thalassian Recipe in a Bottle](https://www.wowhead.com/item=278329/thalassian-recipe-in-a-bottle)
  reports support Careless Cargo/Lost Treasures in original Midnight zones as
  well as The Coiled Isle. The maps target the existing recipe rows, preserve
  their categories, and explain the bound bottle versus individual unused
  recipe output. Conflicting eligibility, duplicate and daily-cap reports do
  not become hard requirements or guaranteed drops.
- [Infused Heliotrope](https://warcraft.wiki.gg/wiki/Infused_Heliotrope)
  retains eligible PvP rewards and the Mirvedon Honor alternative. Silvermoon
  is an unpinned quartermaster-access map, not the required queue location.
  [Galactic Combatant's Heraldry](https://warcraft.wiki.gg/wiki/Galactic_Combatant%27s_Heraldry)
  is a legacy Season 1 reagent whose earning sources have ended. Its map is
  explicitly historical context and does not promise current-season rewards.
- [Coiled Isle gathering research](https://www.method.gg/guides/farming-routes-for-neutralized-venom-clot-and-cursebound-globes-in-wow-midnight)
  supports the post-Curse-Surge Cursed Land and Waters window. Venomous nodes
  require cleansing and collecting the resulting green puddles/orbs for Clot;
  they cannot be Overloaded. Cursed ore/herbs provide Globe and support
  Overload. No permanent node coordinates are inferred from a route image.

## Preservation and validation

- [Coverage report](midnight-missing-map-coverage-2026-10-23.json) exercises the
  real Lua row, option, map-opening and detail builders. It opens all 131 visible
  items, checks that every listed source option is usable, explicitly checks the
  seven Instance items, and exercises 56 filter/search checks. The enriched
  options build 5,904 detail lines with tips, sources and acquisition actions.
  Normal and expanded Materials views share the validated display rows.
- [Source index](midnight-missing-map-source-index-2026-10-23.json) records each
  target's original map availability, evidence keys, input identities and
  inherited route IDs. Its 25 evidence entries distinguish family guidance,
  live tooltip data, player reports and inherited geometry.
- [Tooltip receipts](midnight-missing-map-tooltip-receipts-2026-10-23.json)
  record public Retail retrieval URLs, timestamps and SHA-256 hashes for all
  54 missing-map item identities and two live processing spells. All 56 cached
  responses match their receipt hashes. Raw responses are local research cache,
  not runtime assets.
- Six focused Midnight data checks pass: exact scope and composed/non-target
  preservation, repeated-load stability, input families and complete geometry,
  processing costs, pool/access roles, legacy availability, and map/index details.
  All six TWW map checks and four Cosmetics data checks also pass.
- The broader Materials suite has 52 passes and its existing Nagrand/Twilight
  Ridge versus Catalog/Warmaul ordering failure. The same failure reproduces
  with this enrichment disabled; no Materials UI implementation is changed.
- Manifest validation passes for seven manifests and 259 runtime Lua files.
  All runtime Lua files compile with Lua 5.1. MaterialIndex regeneration is
  byte-identical on a second run, with only the intended 54 flags changed.

Reproduce coverage from the repository root with Python and `lupa`:

```text
python tools/audit_bfa_material_maps.py --expansion midnight --output docs/research/midnight-missing-map-coverage-2026-10-23.json
```

The module loads after CatalogGathering and before Midnight/Finalize. Complete
input-route geometry, exports, source provenance and tips are retained. Existing
paths were not re-surveyed; derived Midnight specialty options remain non-routes.
Source evidence is reviewed by family rather than claiming every linked page
was re-fetched. Exact item identities were independently refreshed through
public Retail tooltip JSON. No measured yields, respawn promises or current
sale prices are inferred.

Static and headless checks do not establish live WoW rendering, spawn behavior,
loot eligibility or farming results. `/reload` and in-game inspection remain
unperformed.
