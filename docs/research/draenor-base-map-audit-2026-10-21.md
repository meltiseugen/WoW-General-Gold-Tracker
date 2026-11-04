# Draenor base Materials map audit - 2026-10-21

The confirmed scope is **Warlords of Draenor**, not Pandaria. All **91 base catalog records** were individually searched and their Retail item tooltips retrieved. **Composed entries, recipes and component chains are excluded and unchanged.** Other expansions are unchanged by this module.

## Result

| Measure | Result |
| --- | ---: |
| Individually searched base records | 91 |
| Retail item tooltips retrieved successfully | 91/91 |
| Base records with Map data | 91/91 |
| Currently visible base rows with Map in the Materials renderer | 89/89 |
| Existing hidden bound-support records with source guidance | 2 |
| Base records with coordinate-backed choices | 83 |
| Base records using only explicit source-area navigation | 8 |
| Map choices across the item index | 875 |
| Distinct coordinate anchors across the index | 1183 |

Before this pass, 14 base records had no map locations. The eight records without coordinate pins now open named source areas: the three archaeology keystones, Fel Ham, Rylak Egg, the two mission rewards and Shadowmoon Lumber. The current list already hides Primal Spirit and Shadowmoon Lumber as bound support; their hidden status was preserved. Draenor has no Perfect Gem category in this base inventory; the existing Perfect gems belong to Pandaria and were not edited.

The choice and coordinate totals include existing supplied routes, existing bundled geometry, separated fishing-water anchors and reused input farms. **They do not represent 875 new independent farms or 1183 newly verified spawns.** The same herb/ore geometry serves fragments, byproducts, pigments and production inputs. Sources establish the acquisition method and named areas; this research does not independently measure every inherited coordinate, spawn density, drop rate or hourly yield.

## Research distinctions

- **Fish:** regional inland species, sea-water species and Tanaan species have separate guidance. Small, normal and enormous variants reuse the correct waters. Every whole-fish tooltip was retrieved individually; current tooltips require five fish of one size to clean. Old 20/10/5 stack advice and historical 700-point skill thresholds are explicitly qualified. The two faction garrison ponds are alternatives where supported, with unlock, bait and size qualifications. Felmouth fish and bait stay in Tanaan. [Fishing overview](https://www.wowhead.com/guide/professions/wod/fishing-overview), [bait rules](https://warcraft.wiki.gg/wiki/Fishing_bait).
- **Cerulean Pigment:** all six standard Draenor herb inputs have gathering choices followed by explicit milling steps. Cracked Draenic Mortar is documented as a possible tool alternative for non-scribes. Milling does not become a deterministic component recipe. [Pigment](https://www.wowhead.com/item=114931/cerulean-pigment), [mortar](https://www.wowhead.com/item=114942/cracked-draenic-mortar).
- **Sorcerous elements:** input farms and both faction garrisons identify the matching profession buildings. Tips explain the intervening production step and random byproduct. Elemental mobs are not advertised as direct sources. No composed recipe or circular conversion graph was introduced. [Work-order source table](https://www.wowhead.com/guide/garrisons/guide-to-garrison-work-orders).
- **Enchanting:** gear-input areas require disenchanting; rare gear can produce dust instead of a shard. Small shards combine ten to one. Fractured Temporal Crystal has Study production guidance and dust-input maps; Temporal Crystal also offers eligible epic-gear sources at Highmaul, Blackrock Foundry and Hellfire Citadel, with loot-lockout qualifications. [Small shard](https://www.wowhead.com/item=115502/small-luminous-shard), [Temporal Crystal](https://www.wowhead.com/item=113588/temporal-crystal).
- **Archaeology:** named possible sites are indexed separately by culture and zone. Choices open their zone and instruct players to follow their character's active Archaeology overlay. They have no fabricated survey-find coordinates. [Archaeology overview](https://www.wowhead.com/guide/professions/wod/archaeology-overview), [Cymre's site inventory](https://www.cymre.com/2014/08/21/draenor-archaeology/).
- **Meat and skinning:** added reported alternatives for boars, riverbeasts, talbuks, elekks, clefthoofs, rylaks and Greater Axebeaks. Kill loot and skinning loot are distinct; scraps and gathering fragments depend on training/skill. Fel Ham uses named Tanaan boar areas without unsupported exact pins. [Fel Egg reports](https://www.wowhead.com/item=128499/fel-egg), [Hulking Diretusk](https://warcraft.wiki.gg/wiki/Hulking_Diretusk), [Riverwallower](https://warcraft.wiki.gg/wiki/Riverwallower).
- **Mission rewards:** Huge Ogre Cache and Frozen Arms of a Hero navigate to faction garrison mission tables. Offers depend on progression and availability; a mission destination is not advertised as an outdoor reward farm. [Huge Ogre Cache](https://warcraft.wiki.gg/wiki/Huge_Ogre_Cache), [Frozen Arms](https://www.wowhead.com/item=128314/frozen-arms-of-a-hero).
- **Shadowmoon Lumber:** reported Draenor woodland areas are scouting choices with no invented fixed tree positions. The item remains Warband-bound; it differs from Garrison Lumber Mill timber. [Harvesting return](https://www.wowhead.com/news/shadowmoon-lumber-returned-to-warlords-of-draenor-zones-in-the-midnight-pre-380372), [item reports](https://www.wowhead.com/item=251766/shadowmoon-lumber).
- Existing single-source limits remain honest: the Pretty Draenor Pearl cave treasure is not padded with imaginary repeatable farms.

## Corrected map/source errors

- Split Sea Scorpion's mixed Nagrand/Frostfire/Spires coordinates into their correct individual zone choices, including all whole-fish sizes and bait.
- Rejected the bundled Townlong Steppes map 388 option attached to Draenor Nagrand Arrowbloom. The gathering snapshot and original supplied route files were not rewritten.
- Replaced the unsupported Fang'rila saberon skinning/fishing option for Felblight with eligible beast, school and limited world-boss alternatives.
- Removed generic green-gear areas as implied direct crystal sources. Their reuse now explicitly requires disenchanting for dust and then Study work orders.
- Replaced Rylak Egg's unsupported nest-object pins with rylak kill-source areas. The Giant Rylak Egg is an assault/achievement object, and source comments explicitly report no item loot. [Object evidence](https://www.wowhead.com/object=235826/giant-rylak-egg).

## Verification

- 9 focused data cases passed in an embedded Lua 5.1 harness: 5 Draenor cases and 4 existing Pandaria regression cases. This was not the normal Busted runner.
- The actual Materials row builder exposed Map on all 89 currently visible base rows. Programmatically opening all 91 base records checked every one of the 875 options and generated 18681 detail rows, with tips/source links present. Coordinate-free source options retained empty pin lists.
- Before/after comparisons verified that every composed research record, other-expansion research record and all catalog definitions/recipes remained unchanged. Repeated module loading was idempotent.
- Manifest validation passed for 6 manifests and 237 runtime Lua files. The focused TOC diff check passed.
- **A live WoW reload, rendered in-game visual inspection and farming yield tests have not been performed.** Existing gathering geometry retains its source confidence and practical limits.

## Reproduce source and coverage audits

```powershell
uv run --offline --no-project python tools/research_material_maps.py --expansion draenor --inventory docs/research/draenor-base-map-source-index-2026-10-21.json --cache .local/draenor-map-sources --output docs/research/draenor-base-map-source-index-2026-10-21.json --refresh
uv run --offline --no-project --with lupa python tools/audit_draenor_material_maps.py --output docs/research/draenor-base-map-coverage-2026-10-21.json
```

The source index records URLs, timestamps and SHA-256 receipts. Search receipts record all 91 individual queries. Coverage JSON indexes each item's named map choices, acquisition actions, zones and source URLs. The runtime data contains the per-choice tips and sources. Unrelated worktree edits were preserved.

## Item-by-item coverage

| Item | ID | Category | Map choices | Zones |
| --- | ---: | --- | ---: | --- |
| [Arakkoa Cipher](https://www.wowhead.com/item=109585) | 109585 | Archaeology Keystone | 9 | Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Draenor Clan Orator Cane](https://www.wowhead.com/item=108439) | 108439 | Archaeology Keystone | 25 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor) |
| [Ogre Missive](https://www.wowhead.com/item=109584) | 109584 | Archaeology Keystone | 15 | Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Primal Spirit](https://www.wowhead.com/item=120945) | 120945 | Bound Crafting Input | 64 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Sumptuous Fur](https://www.wowhead.com/item=111557) | 111557 | Cloth | 5 | Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Talador, Tanaan Jungle |
| [Sorcerous Air](https://www.wowhead.com/item=113264) | 113264 | Elemental | 29 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Sorcerous Earth](https://www.wowhead.com/item=113263) | 113263 | Elemental | 64 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Sorcerous Fire](https://www.wowhead.com/item=113261) | 113261 | Elemental | 31 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Sorcerous Water](https://www.wowhead.com/item=113262) | 113262 | Elemental | 51 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Draenic Dust](https://www.wowhead.com/item=109693) | 109693 | Enchanting | 2 | Talador, Tanaan Jungle |
| [Fractured Temporal Crystal](https://www.wowhead.com/item=115504) | 115504 | Enchanting | 4 | Frostwall, Lunarfall, Talador, Tanaan Jungle |
| [Luminous Shard](https://www.wowhead.com/item=111245) | 111245 | Enchanting | 3 | Shadowmoon Valley (Draenor), Talador, Tanaan Jungle |
| [Small Luminous Shard](https://www.wowhead.com/item=115502) | 115502 | Enchanting | 3 | Shadowmoon Valley (Draenor), Talador, Tanaan Jungle |
| [Temporal Crystal](https://www.wowhead.com/item=113588) | 113588 | Enchanting | 7 | Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Talador, Tanaan Jungle |
| [Abyssal Gulper Eel Flesh](https://www.wowhead.com/item=109143) | 109143 | Fish | 7 | Frostwall, Lunarfall, Spires of Arak |
| [Blackwater Whiptail Flesh](https://www.wowhead.com/item=109144) | 109144 | Fish | 6 | Frostwall, Lunarfall, Talador |
| [Blind Lake Sturgeon Flesh](https://www.wowhead.com/item=109140) | 109140 | Fish | 5 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Crescent Saberfish Flesh](https://www.wowhead.com/item=109137) | 109137 | Fish | 8 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Fat Sleeper Flesh](https://www.wowhead.com/item=109139) | 109139 | Fish | 6 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Felmouth Frenzy](https://www.wowhead.com/item=127991) | 127991 | Fish | 2 | Tanaan Jungle |
| [Fire Ammonite Tentacle](https://www.wowhead.com/item=109141) | 109141 | Fish | 8 | Frostfire Ridge, Frostwall, Lunarfall |
| [Jawless Skulker Flesh](https://www.wowhead.com/item=109138) | 109138 | Fish | 12 | Frostwall, Gorgrond, Lunarfall |
| [Sea Scorpion Segment](https://www.wowhead.com/item=109142) | 109142 | Fish | 5 | Frostfire Ridge, Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
| [Abyssal Gulper Eel Bait](https://www.wowhead.com/item=110293) | 110293 | Fishing Bait | 7 | Frostwall, Lunarfall, Spires of Arak |
| [Blackwater Whiptail Bait](https://www.wowhead.com/item=110294) | 110294 | Fishing Bait | 6 | Frostwall, Lunarfall, Talador |
| [Blind Lake Sturgeon Bait](https://www.wowhead.com/item=110290) | 110290 | Fishing Bait | 5 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Fat Sleeper Bait](https://www.wowhead.com/item=110289) | 110289 | Fishing Bait | 6 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Felmouth Frenzy Bait](https://www.wowhead.com/item=128229) | 128229 | Fishing Bait | 2 | Tanaan Jungle |
| [Fire Ammonite Bait](https://www.wowhead.com/item=110291) | 110291 | Fishing Bait | 8 | Frostfire Ridge, Frostwall, Lunarfall |
| [Jawless Skulker Bait](https://www.wowhead.com/item=110274) | 110274 | Fishing Bait | 12 | Frostwall, Gorgrond, Lunarfall |
| [Sea Scorpion Bait](https://www.wowhead.com/item=110292) | 110292 | Fishing Bait | 5 | Frostfire Ridge, Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
| [Fireweed](https://www.wowhead.com/item=109125) | 109125 | Herb | 8 | Frostfire Ridge, Frostwall, Lunarfall, Spires of Arak, Tanaan Jungle |
| [Frostweed](https://www.wowhead.com/item=109124) | 109124 | Herb | 8 | Frostfire Ridge, Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Gorgrond Flytrap](https://www.wowhead.com/item=109126) | 109126 | Herb | 7 | Frostwall, Gorgrond, Lunarfall, Spires of Arak |
| [Nagrand Arrowbloom](https://www.wowhead.com/item=109128) | 109128 | Herb | 6 | Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
| [Starflower](https://www.wowhead.com/item=109127) | 109127 | Herb | 7 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor), Spires of Arak |
| [Talador Orchid](https://www.wowhead.com/item=109129) | 109129 | Herb | 7 | Frostwall, Lunarfall, Spires of Arak, Talador |
| [Broken Fireweed Stem](https://www.wowhead.com/item=109625) | 109625 | Herb Fragment | 6 | Frostfire Ridge, Spires of Arak, Tanaan Jungle |
| [Broken Frostweed Stem](https://www.wowhead.com/item=109624) | 109624 | Herb Fragment | 6 | Frostfire Ridge, Shadowmoon Valley (Draenor) |
| [Gorgrond Flytrap Ichor](https://www.wowhead.com/item=109626) | 109626 | Herb Fragment | 5 | Gorgrond, Spires of Arak |
| [Nagrand Arrowbloom Petal](https://www.wowhead.com/item=109628) | 109628 | Herb Fragment | 4 | Nagrand (Draenor), Spires of Arak |
| [Starflower Petal](https://www.wowhead.com/item=109627) | 109627 | Herb Fragment | 5 | Shadowmoon Valley (Draenor), Spires of Arak |
| [Talador Orchid Petal](https://www.wowhead.com/item=109629) | 109629 | Herb Fragment | 5 | Spires of Arak, Talador |
| [Raw Beast Hide](https://www.wowhead.com/item=110609) | 110609 | Leather | 8 | Frostfire Ridge, Nagrand (Draenor), Shadowmoon Valley (Draenor), Talador |
| [Raw Beast Hide Scraps](https://www.wowhead.com/item=110610) | 110610 | Leather Scrap | 10 | Frostfire Ridge, Nagrand (Draenor), Shadowmoon Valley (Draenor), Talador |
| [Fel Egg](https://www.wowhead.com/item=128499) | 128499 | Meat | 4 | Tanaan Jungle |
| [Fel Ham](https://www.wowhead.com/item=128500) | 128500 | Meat | 2 | Tanaan Jungle |
| [Raw Boar Meat](https://www.wowhead.com/item=109136) | 109136 | Meat | 4 | Frostfire Ridge, Gorgrond, Tanaan Jungle |
| [Raw Clefthoof Meat](https://www.wowhead.com/item=109131) | 109131 | Meat | 2 | Frostfire Ridge, Nagrand (Draenor) |
| [Raw Elekk Meat](https://www.wowhead.com/item=109134) | 109134 | Meat | 2 | Nagrand (Draenor), Shadowmoon Valley (Draenor) |
| [Raw Riverbeast Meat](https://www.wowhead.com/item=109135) | 109135 | Meat | 2 | Nagrand (Draenor), Talador |
| [Raw Talbuk Meat](https://www.wowhead.com/item=109132) | 109132 | Meat | 2 | Nagrand (Draenor) |
| [Rylak Egg](https://www.wowhead.com/item=109133) | 109133 | Meat | 2 | Shadowmoon Valley (Draenor), Tanaan Jungle |
| [Frozen Arms of a Hero](https://www.wowhead.com/item=128314) | 128314 | Mission Reward | 2 | Frostwall, Lunarfall |
| [Huge Ogre Cache](https://www.wowhead.com/item=128313) | 128313 | Mission Reward | 2 | Frostwall, Lunarfall |
| [Blackrock Ore](https://www.wowhead.com/item=109118) | 109118 | Ore | 14 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Talador, Tanaan Jungle |
| [True Iron Ore](https://www.wowhead.com/item=109119) | 109119 | Ore | 13 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Blackrock Fragment](https://www.wowhead.com/item=109992) | 109992 | Ore Fragment | 12 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Talador, Tanaan Jungle |
| [True Iron Nugget](https://www.wowhead.com/item=109991) | 109991 | Ore Fragment | 11 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Cerulean Pigment](https://www.wowhead.com/item=114931) | 114931 | Pigment | 31 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Felblight](https://www.wowhead.com/item=127759) | 127759 | Reagent | 7 | Tanaan Jungle |
| [Savage Blood](https://www.wowhead.com/item=118472) | 118472 | Reagent | 3 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Medallion of the Legion](https://www.wowhead.com/item=128315) | 128315 | Reputation Item | 4 | Tanaan Jungle |
| [Draenic Seeds](https://www.wowhead.com/item=116053) | 116053 | Seed | 37 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Draenic Stone](https://www.wowhead.com/item=115508) | 115508 | Stone | 28 | Frostfire Ridge, Frostwall, Gorgrond, Lunarfall, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador, Tanaan Jungle |
| [Pretty Draenor Pearl](https://www.wowhead.com/item=108739) | 108739 | Toy | 1 | Frostfire Ridge |
| [Shadowmoon Lumber](https://www.wowhead.com/item=251766) | 251766 | Warband Housing Lumber | 5 | Ashran, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Abyssal Gulper Eel](https://www.wowhead.com/item=111664) | 111664 | Whole Fish | 7 | Frostwall, Lunarfall, Spires of Arak |
| [Blackwater Whiptail](https://www.wowhead.com/item=111663) | 111663 | Whole Fish | 6 | Frostwall, Lunarfall, Talador |
| [Blind Lake Sturgeon](https://www.wowhead.com/item=111667) | 111667 | Whole Fish | 5 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Crescent Saberfish](https://www.wowhead.com/item=111595) | 111595 | Whole Fish | 8 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Enormous Abyssal Gulper Eel](https://www.wowhead.com/item=111671) | 111671 | Whole Fish | 7 | Frostwall, Lunarfall, Spires of Arak |
| [Enormous Blackwater Whiptail](https://www.wowhead.com/item=111670) | 111670 | Whole Fish | 6 | Frostwall, Lunarfall, Talador |
| [Enormous Blind Lake Sturgeon](https://www.wowhead.com/item=111674) | 111674 | Whole Fish | 5 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Enormous Crescent Saberfish](https://www.wowhead.com/item=111601) | 111601 | Whole Fish | 8 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Enormous Fat Sleeper](https://www.wowhead.com/item=111675) | 111675 | Whole Fish | 6 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Enormous Fire Ammonite](https://www.wowhead.com/item=111673) | 111673 | Whole Fish | 8 | Frostfire Ridge, Frostwall, Lunarfall |
| [Enormous Jawless Skulker](https://www.wowhead.com/item=111676) | 111676 | Whole Fish | 12 | Frostwall, Gorgrond, Lunarfall |
| [Enormous Sea Scorpion](https://www.wowhead.com/item=111672) | 111672 | Whole Fish | 5 | Frostfire Ridge, Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
| [Fat Sleeper](https://www.wowhead.com/item=111668) | 111668 | Whole Fish | 6 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Fire Ammonite](https://www.wowhead.com/item=111666) | 111666 | Whole Fish | 8 | Frostfire Ridge, Frostwall, Lunarfall |
| [Jawless Skulker](https://www.wowhead.com/item=111669) | 111669 | Whole Fish | 12 | Frostwall, Gorgrond, Lunarfall |
| [Sea Scorpion](https://www.wowhead.com/item=111665) | 111665 | Whole Fish | 5 | Frostfire Ridge, Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
| [Small Abyssal Gulper Eel](https://www.wowhead.com/item=111659) | 111659 | Whole Fish | 7 | Frostwall, Lunarfall, Spires of Arak |
| [Small Blackwater Whiptail](https://www.wowhead.com/item=111662) | 111662 | Whole Fish | 6 | Frostwall, Lunarfall, Talador |
| [Small Blind Lake Sturgeon](https://www.wowhead.com/item=111652) | 111652 | Whole Fish | 5 | Frostwall, Lunarfall, Shadowmoon Valley (Draenor) |
| [Small Crescent Saberfish](https://www.wowhead.com/item=111589) | 111589 | Whole Fish | 8 | Frostfire Ridge, Gorgrond, Nagrand (Draenor), Shadowmoon Valley (Draenor), Spires of Arak, Talador |
| [Small Fat Sleeper](https://www.wowhead.com/item=111651) | 111651 | Whole Fish | 6 | Frostwall, Lunarfall, Nagrand (Draenor) |
| [Small Fire Ammonite](https://www.wowhead.com/item=111656) | 111656 | Whole Fish | 8 | Frostfire Ridge, Frostwall, Lunarfall |
| [Small Jawless Skulker](https://www.wowhead.com/item=111650) | 111650 | Whole Fish | 12 | Frostwall, Gorgrond, Lunarfall |
| [Small Sea Scorpion](https://www.wowhead.com/item=111658) | 111658 | Whole Fish | 5 | Frostfire Ridge, Frostwall, Lunarfall, Nagrand (Draenor), Spires of Arak |
