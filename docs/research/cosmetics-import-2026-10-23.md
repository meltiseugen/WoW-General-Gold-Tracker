# Drops > Cosmetics

Scope: auctionable items whose Retail tooltip explicitly displays the pink
**Cosmetic** label. TODO-Planner's Cosmetics collection supplies discovery and
acquisition data; membership there alone does not establish eligibility.

## Results

Audited 2,877 distinct item IDs from 62 TODO-Planner expansion/patch files and
The War Within/Midnight fishing entries. Imported 219 items, including 27
fishing cosmetics moved from Materials:

| Expansion | Items |
| --- | ---: |
| Shadowlands | 28 |
| Dragonflight | 80 |
| The War Within | 12 |
| Midnight | 99 |

All included items explicitly carry the Cosmetic tooltip label: 202 bind when
equipped, two bind when used, and 15 have no binding restriction in the tooltip.
Bound rewards, ordinary equipment, and
appearance-learning products without that exact label are excluded. There are
2,646 bound exclusions, 11 other non-Cosmetic exclusions, and one unverifiable
item (`253221`, Appearance: Bulwark of Mannoroth, tooltip endpoint HTTP 404).
The bound decision takes precedence for items failing both criteria. Existing
Darkmoon and augment-rune exclusion policies also apply.

All 12 TWW fishing appearances were removed from FarmingItems, material research,
and the lightweight material index. A lightweight `dropsOnlyItemIDs` guard also
prevents a recorded fishing farm's inferred primary item from recreating
Jeweler's Careful Crusher as a Materials row. Recorded gathering results remain
intact. The two crafted Dragonflight cosmetics (193371 and 194748) remain in
Composed Materials with their ingredient graphs and also appear in Cosmetics.

The Midnight follow-up checks all 20 Fishing Specialty entries against freshly
retrieved Retail tooltips. Fifteen have the exact Cosmetic label and move to
Drops > Cosmetics: nine Lost weapons, four Sanctum staves, and two Farstrider
bows. Their Materials records and index entries are removed, with the same
`dropsOnlyItemIDs` protection. The other five retain their Materials entries:
Definitely Not a Rock (238489), Another's Treasure (238494), Ambiguous Rock
(266102), Writhing Wiggleworm (262650), and Pointed Spikesnail (262651). The first
three are novelty catches; the last two are fishing lures. None has the required
Cosmetic tooltip label. Original Materials research is preserved in the portable
source records, and no composed recipe or unrelated gathering data is changed.

## Evidence and retained acquisition data

- [Eligibility receipts](cosmetic-type-audit-2026-10-23.json): decision, tooltip
  binding/type, public retrieval URL, timestamp, and SHA-256 for every candidate.
- [Portable source index](cosmetic-source-index-2026-10-23.json): original
  collection entries, expansion/patch, source file hashes, detail groups,
  waypoints, and patch source URLs for all selected items.
- [Fishing source preservation](../../tools/cosmetic_primary_sources.json): original
  Materials records and acquisition research, retained for repeatable discovery
  after migration.

Example identity/binding source: [Coreway Engineer's Forceps](https://www.wowhead.com/item=225759).
The audit fetched public Retail tooltip JSON with `dataEnv=1&locale=0`; raw
responses are cached under `.local/cosmetic-sources/` and are not runtime assets.
Auctionability here means the unused item is BoE/BoU or has no tooltip binding
restriction; player-altered or learned
copies are not sale stock.

The 219 rows share 19 acquisition guides. Sources, requirements, original
collection instructions, and patch chronology are preserved in the source
index. Product guides replace instructions to consume collection tokens with
advice to retain the unused item for sale. Relevant source links and item pages
remain available in farm details. Broad unrelated patch links are not displayed.

Inherited waypoints remain navigation/access hints, including vendors, hubs,
and recipe access. No shared hub is presented as an exact drop location. TWW
fishing opens the Khaz Algar source-area map; Midnight fishing uses the Quel'Thalas
overview (2537). Both use source-area navigation without fabricated pins. No
deterministic drop probability, yield, or hourly estimate is inferred. TODO's
acquisition claims and coordinates were preserved, not independently retested
in game. The runtime has no TODO-Planner dependency.

## Regeneration

From the addon root, with Python and `lupa` available:

```text
python tools/research_cosmetic_catalog.py --fetch
python tools/generate_cosmetic_catalog.py
```

The research step reads the sibling TODO-Planner and public tooltips. The build
step reads only the portable source index and eligibility audit and rejects
unverified rows. `Cosmetics.lua` stays separate from the upstream Drops snapshot;
snapshot regeneration therefore cannot erase these curated imports. The
gathering snapshot generator also preserves the Materials exclusion guard.

Regenerate `Data/MaterialIndex.lua` with `tools/generate_material_index.lua` after
changing Materials. After the Midnight migration and intervening catalog cleanup,
the index contains 7,311 records.

## Validation

- All 219 included raw tooltip responses matched their receipt hashes and passed
  the exact-type/binding classifier again.
- Post-migration discovery finds 2,877 candidates and all 27
  fishing appearances; rebuilding the runtime catalog produces identical bytes.
- Three Python eligibility/provenance tests pass.
- Four Cosmetics data checks and all 43 Drops UI checks pass. The migration check
  verifies the exact 15 removals, five retained non-Cosmetics, and Midnight map
  placement. Existing catalog-loader checks have five passes and the same three
  failures reproduced with the saved pre-migration files.
- Headless Lua checks cover migration, retained crafting graphs, unique rows,
  stable farm indexes on repeated loads, source-area maps, inherited pins, resale
  advice, lazy loading, tab selection, and exact Map-button record routing.
- Manifest and Lua 5.1 syntax validation pass. Live WoW rendering, tooltip
  resolution, and world-map interaction still require `/reload` verification.

Existing broader-suite failures remain in Favorites test-widget `SetTexture`
support, an old price-candidate-count assertion, and three farm valuation text
assertions. These are separate from the Cosmetics checks and reproduced with
the pre-change files.
