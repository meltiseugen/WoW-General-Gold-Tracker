# Pandaria base-material map audit — 2026-10-21

Only the **131 base Materials entries** remaining after the earlier category exclusions are in scope. **Composed materials, their recipes and their component chains are excluded.** The existing chance-based Perfect gem entries remain base items; their acquisition guidance does not introduce guaranteed crafting components.

## Result

| Measure | Coverage |
| --- | ---: |
| Individually searched base items | 131 |
| Retail item and source-cut pages retrieved successfully | 198 |
| Entries with Map support | 131/131 |
| Entries with coordinate-backed maps | 127 |
| Entries with source-zone navigation and no invented pins | 4 |
| Perfect gem variants with exact cut/input identity | 67/67 |
| Map alternatives across the item index | 2496 |
| Distinct underlying coordinate anchors | 1142 |

Before this pass, 56 base entries had coordinate-backed research. The remaining 75 consisted of 67 Perfect gems, two pigments, Sparkling Shard, Small Ethereal Shard, three archaeology keystones and Sha Crystal Fragment.

Each Perfect gem now offers **30 input-farm alternatives** across the existing Ghost Iron, Kyparite and Trillium source areas, including the applicable daily farm alternative. The same ore geometry is deliberately reused for different gem colors. These alternatives and shared coordinate anchors must not be counted as independent new spawns.

## Source distinctions and limits

- **Perfect gems:** each exact source-cut spell was retrieved from current Retail tooltip data and checked for its one correct raw-gem reagent. The maps say to gather ore, prospect the needed raw gem, then perform the named cut. The Perfect result remains random, with no claimed fixed proc rate or guaranteed per-output cost. [Jewelcrafting overview](https://www.wowhead.com/guide/mists-of-pandaria-jewelcrafting-overview-1638).
- **Pigments and prospecting shards:** maps show their actual herb or ore inputs. Golden Lotus is excluded from the pigment input list. [Shadow Pigment](https://warcraft.wiki.gg/wiki/Shadow_Pigment), [Misty Pigment](https://warcraft.wiki.gg/wiki/Misty_Pigment), [Sparkling Shard](https://warcraft.wiki.gg/wiki/Sparkling_Shard).
- **Small Ethereal Shard:** mapped cloth/leather input areas support suitable rare equipment followed by disenchanting. Green gear is not advertised as a direct shard source. Test the exact rare item before scaling production. [Rare Misthide Leggings disenchant evidence](https://www.wowhead.com/item=90491/misthide-leggings).
- **Archaeology:** the three keystones have named possible digsites, separated by site and zone. Maps open the relevant zone and explain the character-specific active-site overlay. No permanent digsite or survey-find coordinates are invented. [Digsite list](https://warcraft.wiki.gg/wiki/Archaeology_locations).
- **Sha Crystal Fragment:** maps identify legacy quartermaster source zones and explain eligible former-Valor gear disenchanting. These are purchase/disenchant source areas, not kill farms. Exact contemporary item eligibility, purchase costs, reputation and output must be checked in game before buying. No vendor gear or vendor-only reagent was added to the catalog or recipe components. [Fragment source](https://warcraft.wiki.gg/wiki/Sha_Crystal_Fragment).
- **Vegetables and other restricted sources:** a legitimate personal farm or single rare source is retained when the evidence does not support additional locations. Location counts are not padded with imaginary farms. [Sunsong Ranch](https://warcraft.wiki.gg/wiki/Sunsong_Ranch).
- Existing supplied routes and bundled coordinate sets retain their provenance and yield qualifications. The web checks establish item identity, processing and named source areas; they do not independently validate every old route coordinate or measure current spawn density. No gold-per-hour, proc-rate or drop-rate guarantee is introduced.

## Corrections and additional alternatives

- Excluded the bundled Draenor map 550 route attached to Fool's Cap from this Pandaria base-material map view. The generated gathering snapshot and supplied route definitions were not rewritten.
- Removed a Timeless Isle fallback point incorrectly filed under the Vale and added the documented Ruby Lake anchor on Timeless Isle.
- Moved the Lake of Stars Spinefish alternative to Dread Wastes. Removed coastal Giant Mantis Shrimp locations from Spinefish and the inland Lake of Stars point from coastal shrimp/octopus guidance.
- Added specific alternatives at Sentinel Basecamp, Scritch's northern patrol, Ruby Lake, three Townlong Redbelly Mandarin waters, Nayeli Lagoon, the Yan-Zhe River bridge and the Lake of Stars turtle shoreline. Added applicable Snakeroot, Enigma and Windshear Cactus daily farm alternatives.
- Canonicalized Pandaria map names and kept alternative route choices separate in the map selector.

## Validation

- 49 focused data/UI cases passed in the embedded Lua 5.1 harness. This is not the normal Busted command.
- A headless run of the actual Materials renderer confirmed all 131 base entries expose Map, all 2,496 choices open, and every choice renders tips and source links. Navigation-only choices contain no fake coordinates.
- Regression checks compare the complete FarmingItems catalog and every composed Pandaria research record before/after loading the new module. They are unchanged.
- The broader map suite retains pre-existing route-order/mock limitations. The existing Materials coordinate-option spec expects a different alphabetical order; this same failure was confirmed before the map work. Other broad standalone failures involve cyclic mock comparisons, missing SetHitRectInsets/near harness support and an existing farm-dialog assertion. These are not represented as passing checks.
- Manifest validation passed for all 6 manifests and 236 runtime Lua files. Lua syntax, Python syntax, research JSON parsing and whitespace checks passed. Live Retail /reload, farming efficiency, phasing and actual UI rendering remain unverified.

## Evidence files

- [Per-item source receipts and exact cut reagents](pandaria-base-map-source-index-2026-10-21.json). All 198 source requests use dataEnv=1 (Retail), with retrieval timestamps and response hashes.
- [Search discovery log](pandaria-base-map-searches-2026-10-21.json). All 131 names were individually queried in 33 batches. Search discovery can return Classic/PTR pages; their numerical skill, binding and drop-rate rules were not imported into Retail guidance.
- [Per-item locations and shared coordinate geometry](pandaria-base-map-coverage-2026-10-21.json). Every base item has its own entry and location references.
- Runtime assembly: `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/BaseMaterialMaps.lua`.

## Item-by-item index

Each item links to its Retail item source. Map alternatives include existing sourced locations plus the newly connected input farms. Area-only entries intentionally have no fixed pins.

| Item | ID | Category | Map choices | Zones |
| --- | ---: | --- | ---: | --- |
| [Mantid Amber Sliver](https://www.wowhead.com/item=95373) | 95373 | Archaeology Keystone | 10 (source areas) | Dread Wastes, Townlong Steppes |
| [Mogu Statue Piece](https://www.wowhead.com/item=79869) | 79869 | Archaeology Keystone | 15 (source areas) | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Vale of Eternal Blossoms |
| [Pandaren Pottery Shard](https://www.wowhead.com/item=79868) | 79868 | Archaeology Keystone | 16 (source areas) | Kun-Lai Summit, The Jade Forest, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Sealed Tome of the Lost Legion](https://www.wowhead.com/item=92426) | 92426 | Class Unlock | 1 | Isle of Thunder |
| [Windwool Cloth](https://www.wowhead.com/item=72988) | 72988 | Cloth | 5 | Dread Wastes, Krasarang Wilds, Townlong Steppes, Valley of the Four Winds |
| [Giant Dinosaur Bone](https://www.wowhead.com/item=94288) | 94288 | Collectible Reagent | 1 | Isle of Giants |
| [Mote of Harmony](https://www.wowhead.com/item=89112) | 89112 | Elemental | 4 | Dread Wastes, Kun-Lai Summit, Valley of the Four Winds |
| [Sha Crystal Fragment](https://www.wowhead.com/item=105718) | 105718 | Enchanting | 3 (source areas) | Dread Wastes, Townlong Steppes, Vale of Eternal Blossoms |
| [Small Ethereal Shard](https://www.wowhead.com/item=74252) | 74252 | Enchanting | 10 | Dread Wastes, Isle of Giants, Krasarang Wilds, The Jade Forest, Townlong Steppes, Valley of the Four Winds |
| [Spirit Dust](https://www.wowhead.com/item=74249) | 74249 | Enchanting | 2 | Dread Wastes, Valley of the Four Winds |
| [Emperor Salmon](https://www.wowhead.com/item=74859) | 74859 | Fish | 3 | Krasarang Wilds, Timeless Isle, Valley of the Four Winds |
| [Giant Mantis Shrimp](https://www.wowhead.com/item=74857) | 74857 | Fish | 2 | Dread Wastes, Krasarang Wilds |
| [Golden Carp](https://www.wowhead.com/item=74866) | 74866 | Fish | 3 | Timeless Isle, Valley of the Four Winds |
| [Jade Lungfish](https://www.wowhead.com/item=74856) | 74856 | Fish | 1 | The Jade Forest |
| [Jewel Danio](https://www.wowhead.com/item=74863) | 74863 | Fish | 2 | Timeless Isle, Vale of Eternal Blossoms |
| [Krasarang Paddlefish](https://www.wowhead.com/item=74865) | 74865 | Fish | 3 | Krasarang Wilds, Timeless Isle, Valley of the Four Winds |
| [Redbelly Mandarin](https://www.wowhead.com/item=74860) | 74860 | Fish | 4 | Townlong Steppes |
| [Reef Octopus](https://www.wowhead.com/item=74864) | 74864 | Fish | 3 | Dread Wastes, Krasarang Wilds, The Jade Forest |
| [Spinefish](https://www.wowhead.com/item=83064) | 83064 | Fish | 2 | Dread Wastes, Kun-Lai Summit |
| [Tiger Gourami](https://www.wowhead.com/item=74861) | 74861 | Fish | 1 | Kun-Lai Summit |
| [Alexandrite](https://www.wowhead.com/item=76137) | 76137 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Lapis Lazuli](https://www.wowhead.com/item=76133) | 76133 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Pandarian Garnet](https://www.wowhead.com/item=76136) | 76136 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Roguestone](https://www.wowhead.com/item=76135) | 76135 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Sunstone](https://www.wowhead.com/item=76134) | 76134 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Tiger Opal](https://www.wowhead.com/item=76130) | 76130 | Gem | 32 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Desecrated Herb](https://www.wowhead.com/item=89639) | 89639 | Herb | 3 | Dread Wastes, Kun-Lai Summit, Valley of the Four Winds |
| [Fool's Cap](https://www.wowhead.com/item=79011) | 79011 | Herb | 7 | Dread Wastes, The Jade Forest, Townlong Steppes, Valley of the Four Winds |
| [Golden Lotus](https://www.wowhead.com/item=72238) | 72238 | Herb | 6 | Dread Wastes, The Jade Forest, Valley of the Four Winds |
| [Green Tea Leaf](https://www.wowhead.com/item=72234) | 72234 | Herb | 6 | The Jade Forest, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Rain Poppy](https://www.wowhead.com/item=72237) | 72237 | Herb | 5 | The Jade Forest, Valley of the Four Winds |
| [Silkweed](https://www.wowhead.com/item=72235) | 72235 | Herb | 6 | Valley of the Four Winds |
| [Snow Lily](https://www.wowhead.com/item=79010) | 79010 | Herb | 6 | Kun-Lai Summit, Valley of the Four Winds |
| [Sha-Touched Leather](https://www.wowhead.com/item=72162) | 72162 | Leather | 5 | Dread Wastes, Isle of Giants, The Jade Forest, Townlong Steppes, Valley of the Four Winds |
| [Mushan Ribs](https://www.wowhead.com/item=74834) | 74834 | Meat | 2 | Townlong Steppes, Valley of the Four Winds |
| [Raw Crab Meat](https://www.wowhead.com/item=74838) | 74838 | Meat | 1 | Dread Wastes |
| [Raw Crocolisk Belly](https://www.wowhead.com/item=75014) | 75014 | Meat | 1 | Dread Wastes |
| [Raw Tiger Steak](https://www.wowhead.com/item=74833) | 74833 | Meat | 1 | Valley of the Four Winds |
| [Raw Turtle Meat](https://www.wowhead.com/item=74837) | 74837 | Meat | 3 | Dread Wastes, The Jade Forest, Valley of the Four Winds |
| [Viseclaw Meat](https://www.wowhead.com/item=85506) | 85506 | Meat | 1 | Dread Wastes |
| [Wildfowl Breast](https://www.wowhead.com/item=74839) | 74839 | Meat | 1 | Valley of the Four Winds |
| [Black Trillium Ore](https://www.wowhead.com/item=72094) | 72094 | Ore | 6 | Dread Wastes, Kun-Lai Summit, Townlong Steppes, Valley of the Four Winds |
| [Ghost Iron Ore](https://www.wowhead.com/item=72092) | 72092 | Ore | 11 | Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Valley of the Four Winds |
| [Kyparite](https://www.wowhead.com/item=72093) | 72093 | Ore | 6 | Dread Wastes, Townlong Steppes |
| [White Trillium Ore](https://www.wowhead.com/item=72103) | 72103 | Ore | 7 | Dread Wastes, Kun-Lai Summit, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Accurate Roguestone](https://www.wowhead.com/item=76615) | 76615 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Adept Tiger Opal](https://www.wowhead.com/item=76604) | 76604 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Artful Tiger Opal](https://www.wowhead.com/item=76606) | 76606 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Assassin's Roguestone](https://www.wowhead.com/item=89679) | 89679 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Balanced Alexandrite](https://www.wowhead.com/item=76580) | 76580 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Bold Pandarian Garnet](https://www.wowhead.com/item=76630) | 76630 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Brilliant Pandarian Garnet](https://www.wowhead.com/item=76628) | 76628 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Champion's Tiger Opal](https://www.wowhead.com/item=76599) | 76599 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Crafty Tiger Opal](https://www.wowhead.com/item=76593) | 76593 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Deadly Tiger Opal](https://www.wowhead.com/item=76592) | 76592 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Defender's Roguestone](https://www.wowhead.com/item=76624) | 76624 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Deft Tiger Opal](https://www.wowhead.com/item=76600) | 76600 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Delicate Pandarian Garnet](https://www.wowhead.com/item=76626) | 76626 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Effulgent Alexandrite](https://www.wowhead.com/item=76578) | 76578 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Energized Alexandrite](https://www.wowhead.com/item=76585) | 76585 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Etched Roguestone](https://www.wowhead.com/item=76618) | 76618 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Fierce Tiger Opal](https://www.wowhead.com/item=76603) | 76603 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Fine Tiger Opal](https://www.wowhead.com/item=76607) | 76607 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Flashing Pandarian Garnet](https://www.wowhead.com/item=76629) | 76629 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Forceful Alexandrite](https://www.wowhead.com/item=76588) | 76588 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Fractured Sunstone](https://www.wowhead.com/item=76634) | 76634 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Glinting Roguestone](https://www.wowhead.com/item=76614) | 76614 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Guardian's Roguestone](https://www.wowhead.com/item=76622) | 76622 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Inscribed Tiger Opal](https://www.wowhead.com/item=76595) | 76595 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Keen Tiger Opal](https://www.wowhead.com/item=76605) | 76605 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Lightning Alexandrite](https://www.wowhead.com/item=76576) | 76576 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Lucent Tiger Opal](https://www.wowhead.com/item=76609) | 76609 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Misty Alexandrite](https://www.wowhead.com/item=76574) | 76574 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Mysterious Roguestone](https://www.wowhead.com/item=76619) | 76619 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Mystic Sunstone](https://www.wowhead.com/item=76635) | 76635 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Nimble Alexandrite](https://www.wowhead.com/item=93707) | 93707 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Piercing Alexandrite](https://www.wowhead.com/item=76575) | 76575 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Polished Tiger Opal](https://www.wowhead.com/item=76596) | 76596 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Potent Tiger Opal](https://www.wowhead.com/item=76594) | 76594 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Precise Pandarian Garnet](https://www.wowhead.com/item=76627) | 76627 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Puissant Alexandrite](https://www.wowhead.com/item=76590) | 76590 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Purified Roguestone](https://www.wowhead.com/item=76620) | 76620 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Quick Sunstone](https://www.wowhead.com/item=76633) | 76633 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Radiant Alexandrite](https://www.wowhead.com/item=76583) | 76583 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Reckless Tiger Opal](https://www.wowhead.com/item=76602) | 76602 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Regal Alexandrite](https://www.wowhead.com/item=76587) | 76587 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Resolute Tiger Opal](https://www.wowhead.com/item=76597) | 76597 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Resplendent Tiger Opal](https://www.wowhead.com/item=76613) | 76613 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Retaliating Roguestone](https://www.wowhead.com/item=76617) | 76617 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Rigid Lapis Lazuli](https://www.wowhead.com/item=76570) | 76570 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Sensei's Alexandrite](https://www.wowhead.com/item=76577) | 76577 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Shattered Alexandrite](https://www.wowhead.com/item=76584) | 76584 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Shifting Roguestone](https://www.wowhead.com/item=76621) | 76621 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Skillful Tiger Opal](https://www.wowhead.com/item=76608) | 76608 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Smooth Sunstone](https://www.wowhead.com/item=76631) | 76631 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Solid Lapis Lazuli](https://www.wowhead.com/item=76573) | 76573 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Sovereign Roguestone](https://www.wowhead.com/item=76625) | 76625 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Sparkling Lapis Lazuli](https://www.wowhead.com/item=76572) | 76572 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Splendid Tiger Opal](https://www.wowhead.com/item=76612) | 76612 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Stalwart Tiger Opal](https://www.wowhead.com/item=76598) | 76598 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Steady Alexandrite](https://www.wowhead.com/item=76591) | 76591 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Stormy Lapis Lazuli](https://www.wowhead.com/item=76571) | 76571 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Subtle Sunstone](https://www.wowhead.com/item=76632) | 76632 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Tense Roguestone](https://www.wowhead.com/item=89676) | 89676 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Tenuous Tiger Opal](https://www.wowhead.com/item=76610) | 76610 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Timeless Roguestone](https://www.wowhead.com/item=76623) | 76623 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Turbid Alexandrite](https://www.wowhead.com/item=76582) | 76582 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Veiled Roguestone](https://www.wowhead.com/item=76616) | 76616 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Vivid Alexandrite](https://www.wowhead.com/item=76581) | 76581 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Wicked Tiger Opal](https://www.wowhead.com/item=76601) | 76601 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Willful Tiger Opal](https://www.wowhead.com/item=76611) | 76611 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Perfect Zen Alexandrite](https://www.wowhead.com/item=76579) | 76579 | Perfect Gem | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Misty Pigment](https://www.wowhead.com/item=79253) | 79253 | Pigment | 33 | Dread Wastes, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Shadow Pigment](https://www.wowhead.com/item=79251) | 79251 | Pigment | 33 | Dread Wastes, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Sparkling Shard](https://www.wowhead.com/item=90407) | 90407 | Prospecting Reagent | 30 | Dread Wastes, Krasarang Wilds, Kun-Lai Summit, The Jade Forest, Townlong Steppes, Vale of Eternal Blossoms, Valley of the Four Winds |
| [Blood Spirit](https://www.wowhead.com/item=80433) | 80433 | Raid Reagent | 3 | Dread Wastes, Kun-Lai Summit, The Veiled Stair |
| [Haunting Spirit](https://www.wowhead.com/item=94289) | 94289 | Raid Reagent | 1 | Isle of Thunder |
| [Spirit of War](https://www.wowhead.com/item=102218) | 102218 | Raid Reagent | 1 | Vale of Eternal Blossoms |
| [Hozen Peace Pipe](https://www.wowhead.com/item=86592) | 86592 | Reputation Consumable | 2 | Kun-Lai Summit |
| [Prismatic Scale](https://www.wowhead.com/item=79101) | 79101 | Scale | 5 | Dread Wastes, Isle of Giants, The Jade Forest, Townlong Steppes, Valley of the Four Winds |
| [Green Cabbage](https://www.wowhead.com/item=74840) | 74840 | Vegetable | 1 | Valley of the Four Winds |
| [Jade Squash](https://www.wowhead.com/item=74847) | 74847 | Vegetable | 1 | Valley of the Four Winds |
| [Juicycrunch Carrot](https://www.wowhead.com/item=74841) | 74841 | Vegetable | 1 | Valley of the Four Winds |
| [Mogu Pumpkin](https://www.wowhead.com/item=74842) | 74842 | Vegetable | 1 | Valley of the Four Winds |
| [Pink Turnip](https://www.wowhead.com/item=74849) | 74849 | Vegetable | 1 | Valley of the Four Winds |
| [Red Blossom Leek](https://www.wowhead.com/item=74844) | 74844 | Vegetable | 1 | Valley of the Four Winds |
| [Scallions](https://www.wowhead.com/item=74843) | 74843 | Vegetable | 1 | Valley of the Four Winds |
| [Striped Melon](https://www.wowhead.com/item=74848) | 74848 | Vegetable | 1 | Valley of the Four Winds |
| [White Turnip](https://www.wowhead.com/item=74850) | 74850 | Vegetable | 1 | Valley of the Four Winds |
| [Witchberries](https://www.wowhead.com/item=74846) | 74846 | Vegetable | 1 | Valley of the Four Winds |
| [Bamboo Lumber](https://www.wowhead.com/item=251763) | 251763 | Warband Housing Lumber | 1 | The Jade Forest |

## Refresh the source receipts

The prior index can serve as the next run's input. Raw responses stay in the chosen cache. Add `--refresh` to retrieve them again.

```powershell
python tools/research_material_maps.py --expansion pandaria --inventory docs/research/pandaria-base-map-source-index-2026-10-21.json --cache "$env:TEMP/ggt-pandaria-map-sources" --output docs/research/pandaria-base-map-source-index-2026-10-21.json --refresh
```

Unrelated pre-existing worktree edits were preserved.
