# BfA Materials cleanup and missing maps - 2026-10-23

The actual Materials row builder initially showed 83 BfA entries outside Composed materials, including eight without Map. Removing Battle-Scarred Augment Rune and the duplicate Great Sea Ray leaves 81 visible entries and seven missing-map targets. The Raid items filter contributes one visible entry, Recipe: Heartsbane Hexwurst, and is included in this audit. Existing bound support entries retain their hidden status. All 621 Composed records and their recipe graphs are outside the map-enrichment scope.

## Catalog cleanup

- Removed both existing augment-rune products from all runtime catalogs: Battle-Scarred and Veiled. Updated the BfA and Shadowlands research target arrays, source records and earlier data expectations. Other expansions had no augment-rune catalog products.
- Added augment-rune IDs and name filtering to the shared snapshot exclusion policy, including RareScanner loot filtering. Materials also rejects augment-rune names/tags so custom or session-derived product rows cannot reintroduce them into its list. This does not rewrite the player's inventory or session history.
- Removed Great Sea Ray from the Materials product list, material research, lightweight index and incidental Materials fishing guidance. It already exists once in Drops > Mounts with one indexed guide and two fishing maps; retained that existing entry and its research.

## Missing-map evidence

| Item | Acquisition and map choices | Evidence |
| --- | --- | --- |
| Ultramarine Pigment (153635) | 30 existing input-herb locations; gather herbs, then use Inscription Milling | [Milling's item/yield table](https://www.wowhead.com/spell=51005/milling), [profession milling table](https://www.wow-professions.com/guides/milling-table-inscription) |
| Crimson Pigment (153636) | The same 30 eligible herb locations, retaining each distinct source choice | [Item and milling reports](https://www.wowhead.com/item=153636/crimson-pigment), [profession table](https://www.wow-professions.com/guides/milling-table-inscription) |
| Viridescent Pigment (153669) | The same 30 locations; random milling output rather than a fixed gathering yield | [Firsthand milling reports](https://www.wowhead.com/item=153669/viridescent-pigment) |
| Maroon Pigment (168662) | Five existing Zin'anthid source choices in Nazjatar, followed by Milling | [Milling's Zin'anthid row](https://www.wowhead.com/spell=51005/milling), [profession table](https://www.wow-professions.com/guides/milling-table-inscription) |
| Etched Drust Bone (154990) | Three navigation-only choices: Drustvar, Tiragarde Sound and Stormsong Valley; Survey active Drust digsites | [Archaeology field research](https://www.cymre.com/2018/06/01/archaeology-in-bfa/), [digsite list](https://warcraft.wiki.gg/wiki/Archaeology_locations), [keystone identity](https://www.wowhead.com/item=154990/etched-drust-bone) |
| Zandalari Idol (154989) | Three navigation-only choices: Zuldazar, Nazmir and Vol'dun; Survey active Zandalari digsites | [Archaeology field research](https://www.cymre.com/2018/06/01/archaeology-in-bfa/), [digsite list](https://warcraft.wiki.gg/wiki/Archaeology_locations), [keystone identity](https://www.wowhead.com/item=154989/zandalari-idol) |
| Recipe: Heartsbane Hexwurst (163833) | One dungeon-access pin in Drustvar, 33.89 / 13.14; defeat Raal the Gluttonous inside Waycrest Manor | [Recipe drop and Normal-difficulty reports](https://www.wowhead.com/item=163833/recipe-heartsbane-hexwurst), [published entrance coordinates](https://www.wowhead.com/zone=9424/waycrest-manor) |

Pigment maps copy the existing herb source choices without altering the originals: coordinates, order, route exports, tips and provenance are retained. Output-specific instructions distinguish the input herb from the pigment, disclose random yields, and distinguish Inscription Milling from [housing dye processing](https://us.forums.blizzard.com/en/wow/t/so-confused-about-milling/2217291). These derived maps follow the existing Materials convention of showing non-herb/non-ore inputs as source pins. They are not newly measured gathering routes.

Archaeology locations rotate, so zone navigation intentionally has no invented keystone spawn pins. The Waycrest coordinate marks the outdoor entrance, not Raal's room. All new options are marked `inGameTested = false`; no spawn frequency, guaranteed drops, hourly yield or current market value is asserted.

## Validation

- Seven focused data/cleanup checks passed in embedded Lua 5.1: only the seven missing research records change, all other records and composed recipes remain identical, loading twice is idempotent, input-herb chains are correct, and Great Sea Ray remains exactly once in Drops > Mounts.
- The actual row/map/detail builders show Map for all 81 visible entries and the Raid items recipe. All 102 new choices open with acquisition instructions, tips and source links, producing 2,741 detail lines in the headless harness. All seven targets are discoverable through search. Normal and expanded Materials views share the same verified display rows.
- Regenerated `Data/MaterialIndex.lua`: exactly seven `hasMap` flags change and the three removed products disappear; no other index entries change relative to the starting working tree.
- Mount guide checks passed (3/3). The broader data suite has 114 passed and 18 failed; all 18 failures reproduce against the starting working tree. The Materials UI suite has 49 passed and one pre-existing Nagrand/Warmaul map-order failure. Generator checks exercise the real Drops emitter and RareScanner parser, confirming rune exclusion while retaining Great Sea Ray.
- Direct tooltip requests were blocked by local socket permissions (WinError 10013). Indexed public pages, firsthand comments and guides supplied the reviewed evidence; this pass does not claim fresh tooltip downloads. The source index records the failed attempts and fallback evidence explicitly.
- Live WoW rendering, availability and actual farming remain untested. Use `/reload` to verify the list, map dropdowns, source-area navigation and Raid items recipe in game.

Artifacts: [source evidence](bfa-missing-map-source-index-2026-10-23.json), [map coverage and headless flow results](bfa-missing-map-coverage-2026-10-23.json). Reproduce the map audit with `python tools/audit_bfa_material_maps.py --output docs/research/bfa-missing-map-coverage-2026-10-23.json` in an environment with `lupa`.
