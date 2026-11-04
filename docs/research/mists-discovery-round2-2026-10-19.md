# Pandaria discovery round 2 ? non-ore/non-herb Auction House targets

Researched for **Retail on 2026-10-19**. This is an incremental pass over the existing Pandaria research, not a replacement of its 909 recipe definitions or separate gathering routes.

Added **138 records**: **135 auctionable products** and **three short-lived, farmable recipe-support inputs** explicitly marked `auctionable = false`. Removed one earlier vendor-only support record (Fresh Mangos). Every added catalog row, research record, and source spot explicitly uses `isRoute = false`.

## Additions

| Category | New records | Notes |
| --- | ---: | --- |
| Specialty farm products | 11 | Hozen Peace Pipe, Giant Dinosaur Bone, Viseclaw Meat, Sha Crystal Fragment, Direhorn Runt, Pygmy Direhorn, Spawn of G'nathus, and all four Tiny Carp |
| Cocoon bonus pets | 2 | Imperial Moth and Imperial Silkworm; chance rewards, not one pet per Imperial Silk craft |
| Individual Darkmoon cards | 32 | Complete Ace-through-Eight sets of Tigers, Oxen, Cranes, and Serpents; random card generation is labeled |
| Composed Darkmoon decks | 4 | Exactly one of each of the eight matching cards |
| Composed Darkmoon relic choices | 5 | One completed deck per quest reward; the two Xuen relics are alternative choices, not two rewards from one deck |
| Perfect gem outputs | 67 | Current, tradeable item variants linked to the matching ordinary cut; no guaranteed output probability or per-perfect component price |
| Additional deterministic profession recipes | 14 | Two blacksmithing, two jewelcrafting, ten cooking recipes |
| Perishable farmable support inputs | 3 | Delicate Blossom Petals, Fresh Silkfeather Hawk Eggs, Fresh Shao-Tien Rice; two-hour duration, no AH claim |

The fourteen additional profession recipes are Avenger's Trillium Waistplate, Contender's Spirit Boots, Energized Wild Jade, Revitalizing Primal Diamond, Noodle Cart Kit, Deluxe Noodle Cart Kit, Pandaren Treasure Noodle Cart Kit, Swirling Mist Soup, Mad Brewer's Breakfast, Banquet of the Wok, Viseclaw Soup, Spiced Blossom Soup, Farmer's Delight, and Fluffy Silkfeather Omelet.

The three noodle cart recipes produce **five kits per craft**. The four eight-card assembly recipes bring the number of new deterministic spell/assembly definitions to **18**, and the existing exact Mists recipe check now covers **927** definitions. Five additional composed quest exchanges link the relic rewards to their decks.

## Research and source distinctions

- **Item binding and quantities:** [current Retail Wowhead tooltips](https://nether.wowhead.com/) were fetched separately for each selected item and recipe. The [structured evidence](mists-discovery-round2-2026-10-19.json) contains 248 item/spell tooltip records, parsed component quantities, output batches, vendor omissions, and selected source references. Binding checks inspect the item's own binding field rather than binding language in an embedded recipe result.
- **Discovery index:** [AllTheThings' current Pandaria craftables](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/05%20-%20Mists%20of%20Pandaria.lua) and [Retail reagent index](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua) identified omissions. Ackis Recipe List's Jewelcrafting index supplied a secondary recipe-ID check. These indexes identify candidates; current tooltips supply the recipe quantities.
- **Rare consumable:** [Scritch source research](https://wowrarespawns.blogspot.com/2012/12/kun-lai-summit-rare-champions.html) documents Hozen Peace Pipe as a tradeable drop. The [current NPC page](https://www.wowhead.com/npc=50831/scritch) and current item tooltip also list the drop. The seven-day consumption cooldown is not treated as a respawn timer.
- **Fishing pets:** [El's firsthand Tiny Carp research](https://www.elsanglin.com/catching_tiny_carp.html) distinguishes the four colors' pool types. Current Retail item tooltips separately establish that the unlearned items are not bound. Historical numeric fishing-skill requirements and catch rates are not asserted as current Retail facts.
- **Cocoon pets:** [the tailoring overview](https://www.wowhead.com/guide/mists-of-pandaria-tailoring-overview-1064) and [Imperial Moth source comments](https://www.wowhead.com/npc=67230/imperial-moth) identify the Silkworm Cocoon chance rewards. The daily Imperial Silk spell tooltip was checked separately. Song of Harmony is not advertised as producing cocoons or guaranteed pets.
- **Crab material:** [Viseclaw Meat](https://warcraft.wiki.gg/wiki/Viseclaw_Meat) and [Raw Crab Meat source comments](https://www.wowhead.com/item=74838/raw-crab-meat) document overlapping Muck Sifter farming. The ordinary reagent is distinct from quest-only Polluted Viseclaw Meat.
- **Darkmoon cards:** Each card's current tooltip states its exact set; the four assembly spells list all eight cards. The generated random placeholder item 79318 remains excluded. [Darkmoon deck and reward relationships](https://warcraft.wiki.gg/wiki/Darkmoon_card) provide the quest-exchange cross-check. No Classic-only Faire schedule is imposed on Retail.

## Housing and existing material coverage

All **21 existing Pandaria housing recipes** were fetched again and their complete reagent lists compared with the earlier source snapshot. **All 21 matched**, so no replacement quantities or duplicate decor entries were added. This includes the alchemist's kit/retort, braziers, furniture, cooking decor, engineering decor, stonework, leatherworking furniture, rug, and fishing net.

[Blizzard's housing profession announcement](https://news.blizzard.com/en-us/article/24234113/midnight-housing-rewarding-decor) explains the cross-expansion profession demand. The catalog retains the existing Windwool, leather, hides, scales, fish, Harmony reagents, raid spirits, bound intermediates, and Bamboo Lumber support. Bamboo Lumber is Warband-bound and is not presented as an AH commodity.

## Vendor policy and corrections

Vendor-only products and supplies are excluded. Buying a **recipe** from a trainer or reputation vendor does not make its crafted output vendor-only.

The displayed farmable component lists omit five Ginseng Tea from the basic noodle cart, one vendor Black Pepper from Mad Brewer's Breakfast, one 100 Year Soy Sauce from Banquet of the Wok, and one Fresh Strawberries from Farmer's Delight. Their full reagent lists and omitted quantities remain in the evidence. These are **farmable-input costs**, not complete purchase costs.

The [historical Vale cooking source](https://www.cymre.com/2013/09/20/cooking-in-the-vale/) distinguishes gathered ingredients from Merchant Tantan's supplies. It exposed an earlier mistake: **Fresh Mangos (102540) are vendor-only**. This pass removes that existing support row and research record and omits five Fresh Mangos from **Mango Ice (101745)**. Mango Ice remains a composed recipe using its farmable Aged Balsamic Vinegar; its label states the vendor omission. This correction supersedes the earlier snapshot's Fresh Mangos support classification.

Bound Primal Eggs, bound loot crates, quest clam meat, retired XP elixirs, and unverified historical recipe-scroll drop farms were not added as sale products. Bound pet items such as Spineclaw Crab were not priced as their separately traded pet cages.

## Source pins and uncertainty

The new farms expose **10 source spots / 14 pins**. These are named scouting areas, an outdoor raid entrance, historical patrol interception points, or existing fishing-area anchors. They are not guaranteed item spawns or verified optimal loops. Isle of Giants pins reuse the bundled skinning catalog's coordinates without importing its recorded yield. Horridon's marker is the outdoor Throne of Thunder entrance, not an invented indoor boss position.

Historical drop behavior, phasing, spawn frequency, cast counts, and present-day farming efficiency still require Retail verification. No AH price, sale rate, profit, or gold-per-hour guarantee was introduced.

## Validation

- Focused live-data audit passed for all **138** additions, all **101** chance outputs, component resolution/cycles, vendor exclusions, metadata, and **14** rendered map pins.
- All earlier catalog rows remain semantically unchanged except the two documented vendor corrections. All earlier material-index entries are unchanged. Only this round's 138 index entries were added.
- Raw Pandaria Ore/Herb catalog definitions are textually unchanged from the pre-change snapshot. Existing route modules were not edited.
- Added two regression cases covering specialty flags/binding distinctions, complete card sets, chance-output costing, relic choices, noodle-cart batches, and vendor exclusions.
- The Lua fallback data runner is **100 passed / 9 failed**, compared with **98 passed / 9 failed** before this round. The nine failing case names are unchanged; they concern pre-existing source/schema coverage and existing route-option expectations.
- Manifest validation passed: **6 manifests / 213 runtime Lua files**. Targeted whitespace validation passed.
- Validation used the installed Lua language-server runtime (Lua 5.5) and a minimal assertion runner. The normal Busted suite and live WoW `/reload` verification were not run.

## Files changed in this round

- `Data/FarmingItems.lua`: 138 new rows, Fresh Mangos removal/Mango Ice correction, and catalog data-version increment.
- `Data/MaterialIndex.lua`: 138 new lightweight discovery entries.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots.lua`: material data-version increment.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Miscellaneous.lua`: new source records, qualifications, and Fresh Mangos removal. Existing Crafting.lua automatically attaches composed metadata.
- `tests/data/farming_data_spec.lua`: new regression cases and adjusted recipe/support expectations.
- `docs/research/mists-discovery-round2-2026-10-19.json` and this document: source facts, exclusions, and validation evidence.

Unrelated worktree changes were preserved.
