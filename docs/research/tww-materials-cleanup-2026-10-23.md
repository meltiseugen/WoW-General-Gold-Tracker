# The War Within Materials cleanup

## Changes

- Moved **Writhing Transmutagen** (item **223487**, battle-pet species **4482**)
  from Materials to **Drops > Pets**. The Materials catalog, acquisition record,
  and lightweight index no longer contain it. Pet pricing and map actions use
  the species identity; the original acquisition item is retained as metadata.
- Renamed the shared Materials divider and final browsing option to
  **Instance items**. Existing `raidItems` filter IDs and `raidMaterials`
  expand/collapse state remain compatible with saved selections.
- Extended instance-source recognition to explicit delve tags/acquisition types
  and nested delve spots. The five TWW reagents now appear inside the collapsed
  instance group, including when browsing their original professions:

| Item | ID |
| --- | ---: |
| Ringing Deeps Ingot | 221754 |
| Vial of Kaheti Oils | 221756 |
| Gloomfathom Hide | 221757 |
| Profaned Tinderbox | 221758 |
| Viridian Charmcap | 221763 |

The shared rule also includes Midnight's existing Petrified Root (251285), whose
research already has a delve source. Across all expansions, the group grows
from 77 to 83 records, retaining all 77 previous instance entries. No Midnight
item data was changed. The five listed reagents are the only TWW grouping changes.

Profession assignments and all crafting ingredient graphs remain intact.
Comparing the pre-change and current FarmingItems, Materials research and
MaterialIndex files shows only removal of the single pet record. The regenerated
lightweight index contains 7,326 items.

## Pet acquisition evidence

[WarcraftPets](https://www.warcraftpets.com/wow-pets/magic/oozes-and-slimes/writhing-transmutagen/)
identifies the pet as cageable, its acquisition item as bind-on-use, and
Thaumaturgy as the source. Its main note mentions Storm Dust; a player report
also describes a transmutagen input. [Wowhead item reports](https://www.wowhead.com/item=223487/writhing-transmutagen)
and [Xu-Fu's pet entry](https://www.wow-petguide.com/Pet/222359/Writhing_Transmutagen?sel_lang=en)
corroborate the random Thaumaturgy result. The species ID matches the owned
TODO-Planner catalog and the public species listing; NPC ID 222359 is distinct
from species ID 4482 and acquisition item 223487.

The guide describes the Alchemy/Thaumaturgy unlock and consumed-input attempts.
It does not require expensive rank-three Storm Dust or copy an unverified proc
rate, yield or profit claim. The original unused item can be sold, or the learned
pet can be caged. Bound transmutagen reagents are distinguished from the pet.

The Khaz Algar map is expansion/profession context only, with no fabricated
creature spawn or mandatory crafting-location pin. The existing pet map builder
now retains explicit source-area map metadata for this profession activity.

## Delve classification evidence and scope

The [archived Blizzard hotfix text](https://www.bluetracker.gg/wow/topic/eu-en/531278-the-war-within-hotfixes-16-october/)
names the same five delve reagents in the October 1, 2024 Heavy Trunk changes.
The [pouch reference](https://warcraft.wiki.gg/wiki/Delver%27s_Pouch_of_Reagents)
also enumerates them and marks that pouch removed in 12.0.1. This classification
change does not add a removed pouch, new farming locations, current drop-rate
claims or vendor-only supplies. Existing reagent research and map data remain
unchanged.

The original official hotfix URL and a direct Wowhead NPC/species request were
unreadable during this pass; they were not counted as newly reviewed evidence.
Readable database/guide and archived hotfix text supplied the checks above.

## Validation

- Three new real-catalog checks pass: pet migration and species-specific farm
  lookup, all five reagent placements and retained ingredient uses, and shared
  normal/expanded Materials display rows.
- All four pet-farm tests and all 43 Drops-window tests pass, including the
  actual Pets-tab row and its exact species Map action.
- Materials UI tests pass 52 cases. The existing Nagrand/Twilight Ridge versus
  Catalog/Warmaul map-ordering failure also reproduces with pre-change files.
  The metadata tests now cover delve recognition in catalog rows, research
  records and nested spots, alongside prior dungeon and instance cases.
- The real-catalog filter audit passes all **236 expansion/browsing-option
  combinations**, retaining the original 77 grouped items and adding the six
  explicitly delve-sourced entries above. Its [coverage summary](tww-instance-items-coverage-2026-10-23.json)
  records the exact additions.
- Seven manifests and 257 runtime Lua files validate. Runtime files and the new
  test parse under Lua 5.1; focused diff/whitespace checks pass.

These are static/headless checks. Live WoW `/reload`, rendering and pet-tooltip
verification remain unperformed.
