# Shadowlands Materials category and missing maps - 2026-10-23

Moved all 17 Protoform lattices from Miscellaneous to the **Protoform Lattices** profession-dropdown category. It is available for Shadowlands and All expansions, hidden for other expansions, and excluded from item-assignment menus. Selecting a different expansion resets an incompatible category selection to All professions. Saved or stale category selections are also normalized, and normal/expanded list modes use the same results.

The actual Materials row builder has 76 visible non-Composed Shadowlands entries. Six had no Map before this pass. The Raid items filter was explicitly checked: it currently has zero visible Shadowlands entries, so there are no additional raid/dungeon map gaps. All 343 Composed entries, recipe quantities and component graphs are unchanged. The bound Arden Lumber support entry remains hidden and unchanged.

## Source review and maps

| Missing item | Map choices | Acquisition evidence |
| --- | ---: | --- |
| Umbral Pigment (173056) | 38 | Gather a named Shadowlands herb, then use Inscription Milling. [Profession instructions](https://www.wow-professions.com/guides/shadowlands-inscription-leveling-guide), [milling table](https://www.wowhead.com/spell=51005/milling) |
| Luminous Pigment (173057) | 38 | Same seven herb inputs, retaining all distinct existing source choices. [Profession instructions](https://www.wow-professions.com/guides/shadowlands-inscription-leveling-guide), [First Flower milling reports](https://www.wowhead.com/item=175788/tranquil-pigment) |
| Tranquil Pigment (175788) | 38 | Random Milling output; Nightshade and First Flower are documented sources, while ordinary herbs can produce it less frequently. No fixed output quantities are asserted. [Firsthand milling results](https://www.wowhead.com/item=175788/tranquil-pigment), [milling table](https://www.wowhead.com/spell=51005/milling) |
| Twilight Bark (177061) | 4 | Chance mining byproduct from Phaedrum and Rich Phaedrum Deposits in Ardenweald. [Item tooltip and firsthand reports](https://www.wowhead.com/item=177061/twilight-bark), [source overview](https://warcraft.wiki.gg/wiki/Twilight_Bark) |
| Poultrid Lattice (189148) | 1 | Source-area navigation for interactable Avian Nests in Zereth Mortis. [Firsthand nest report](https://www.wowhead.com/item=189148/poultrid-lattice), [Protoform acquisition table](https://www.icy-veins.com/wow/protoform-synthesis-mount-and-pet-guide) |
| Korthite Crystal (186017) | 3 | Separate Korthia navigation choices for offered daily-quest rewards, eligible treasure/rare loot and the Shaping Fate weekly reward. [Korthia activities and weekly reward](https://www.wowhead.com/guide/korthia-comprehensive-guide), [daily quest availability](https://www.icy-veins.com/wow/korthia-zone-overview-and-guide) |

Pigment maps copy Death Blossom, Marrowroot, Rising Glory, Vigil's Torch, Widowbloom, Nightshade and First Flower locations. Their actions explain gathering followed by Milling, rather than implying pigments are direct plant drops. The maps distinguish legacy Inscription Milling from housing dye processing. Twilight Bark copies all four existing Phaedrum source choices, including the complete 125-point supplied route; original inputs and imported route data are untouched. Derived non-herb/non-ore maps follow the existing source-pin rendering rules.

Nest availability and Korthia activities are dynamic. Their four options intentionally open a source zone with no fabricated fixed coordinates. Poultrid's possible mob source is an uncertain single report, so it is not presented as a confirmed alternative farm. Historical vendor listings for Twilight Bark are disclosed without claiming current stock. Every new choice is marked `inGameTested = false`; no measured spawn frequency, hourly yield, drop rate or current price is claimed.

Research used indexed public pages, firsthand comments and profession/source guides reviewed on 2026-10-23. Existing herb/mining route provenance is retained; this pass does not independently validate every inherited coordinate or claim fresh raw tooltip downloads. The [source index](shadowlands-materials-source-index-2026-10-23.json) records the evidence for each target.

## Validation

- Four new data checks pass in embedded Lua 5.1: exact six-item map scope, idempotence, all 17 category assignments/index entries, correct processing/mining inputs, and navigation-only options without fabricated pins.
- Three new UI checks pass for dropdown visibility, filtering/Miscellaneous removal, assignment-menu separation, All expansions selection, expansion-switch reset and stale selections. The full Materials UI suite has 52 passed and one existing Nagrand/Warmaul map-order failure.
- All 10 existing Shadowlands data checks pass after updating their dynamic-source expectations. BfA map checks (4) and catalog cleanup checks (3) also pass.
- The real row/map/detail builders expose working maps for all 76 visible entries, including all 17 lattice-category rows. The six targets provide 122 new choices and 3,252 headless detail lines with actions, tips and sources. Search finds all six targets, and normal/expanded list modes share the verified rows.
- Comparison against the starting dirty working tree confirms that exactly 17 item profession assignments change; every recipe and other product field stays identical. Regenerated `Data/MaterialIndex.lua` changes only those 17 assignments and six map flags, with one overlapping item; no index entries are added or removed.

Reproduce the headless map/category audit with `python tools/audit_bfa_material_maps.py --expansion shadowlands --output docs/research/shadowlands-materials-coverage-2026-10-23.json` in an environment with `lupa`. [Full map coverage](shadowlands-materials-coverage-2026-10-23.json) includes all new source choices, pins and guidance.

Live WoW rendering and actual farming are untested. After `/reload`, inspect the dropdown under Shadowlands, All expansions and another expansion, all 17 lattice rows, the six new maps, and both list modes.
