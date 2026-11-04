# Legion specialty discovery and composed crafting

Researched **2026-10-19** for current Retail. This pass adds **468 entries**: **457 saleable products** and **11 bound support inputs** required by saleable crafts. The Legion catalog now contains 531 entries. The two existing bound reagents, Blood of Sargeras and Primal Sargerite, are also explicitly labeled as support inputs.

There are **381 composed crafts**, **32 named random Darkmoon cards**, and **55 specialty/support records**. The composed crafts include **23 housing decor recipes**. Every new item, research record and mapped spot has `isRoute = false`. Existing Legion herb and ore module contents are unchanged, including all supplied route imports.

No new raw ore, herb, or vendor-only product was added. Existing herbs and ores remain valid ingredients when expanding a crafted item's components. Purchased supplies are omitted from the new compositions and named in the recipe labels; those costs are therefore the farmable/crafted portion of the recipe, not its entire purchase cost.

## Sources and recipe selection

- The [AllTheThings Legion crafted-item index](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/07%20-%20Legion.lua) and [Retail reagent index](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua) provide discovery candidates and creating spell IDs. Reagent cost values are not assumed to be output batch sizes.
- Ackis profession recipe lists expand discovery, especially glyphs. Current Retail Wowhead item/spell tooltips supply binding, ingredient quantities, output quantities, recipe ranks, source requirements and chance-output notes. Recipe alternatives are retained in the [machine-readable archive](legion-specialty-2026-10-19.json).
- One available recipe is recorded for each output, normally the first rank. A rank-one composition is not a claim that it is the cheapest recipe. Station requirements are included where applicable, including the Dalaran Alchemy Station and the Firmament Stone for Demonsteel Bars.
- [Blizzard's profession housing announcement](https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era) establishes the use of legacy materials for decor. The loaded quantities come from current individual spell tooltips, rather than the original announcement totals. The [current profession housing guide](https://www.wowhead.com/guide/player-housing/crafting-decor-items) explains lumber and finished-decor binding.
- [Feathered Luffa's live item page](https://www.wowhead.com/item=142332/feathered-luffa) supplies an independently verified exception: its created-by table records spell 230047, one output and ten Pristine Falcosaur Feathers. The separate spell tooltip endpoint returns 404. The live page identifies Legion Tailoring, and the [profession update](https://www.wowhead.com/guide/professions-in-patch-7-1) identifies the Wardens recipe source.

## Craft coverage

| Profession | Composed outputs | Examples and treatment |
| --- | ---: | --- |
| Alchemy | 24 | Healing/mana/rejuvenation potions, movement and utility potions, combat potions, flasks, alchemist stones, Argus elixirs and two decor fountains/pools. Extra proc output is not priced as guaranteed. |
| Blacksmithing | 30 | Leystone/Demonsteel armor, Demonsteel Bars, spikes, stirrups, hoofplates, Steelbound Harness, Rethu's belt, Empyrial Breastplate and decor. |
| Cooking | 23 | Individual meals, nested feast recipes, Crispy Bacon, Spiced Falcosaur Omelet and Feast of the Fishes. Actual serving batches are retained. |
| Enchanting | 37 | Ring/cloak/neck enchants, gathering/surveying enchants, pets, relics and decor. Scroll recipes explain applying to purchased vellum; vellum is omitted. |
| Engineering | 37 | Headguns, cranial cannons, Skullblasters, Gunshoes, Auto-Hammers, Reaves modules, mechanical pet, toys and decor. Required bound Reaves parts are support inputs. |
| Inscription | 100 | Glyphs/grimoires, Vantus runes, tomes/codex, relics, toys, tarot, songs, six decor outputs and four deterministic eight-card trinket assemblies. |
| Jewelcrafting | 46 | Cut gems, rings, class necklaces, Saber’s Eyes, lockpicks, toys, Argus crowns and decor. Random prospecting is recorded separately. |
| Leatherworking | 45 | Warhide/Dreadleather/Battlebound/Gravenscale armor, drums, barding, leather toys, crafted legendaries, Argus shoulders and decor. |
| Tailoring | 39 | Silkweave/Imbued Silkweave armor and cloaks, cloth, bags, bandages, Feathered Luffa, clothes chests, legendary shoulders, Lightweave Breeches and decor. |

## Specialty sources

| Item group | Acquisition and qualifications |
| --- | --- |
| [Falcosaur Egg](https://www.wowhead.com/item=142336/falcosaur-egg) and [Pristine Falcosaur Feather](https://www.wowhead.com/item=142335/pristine-falcosaur-feather) | Loot falcosaurs, especially nests and nest-keepers. Four independent nesting-area markers cover Azsuna, Stormheim, Val'sharah and Highmountain. Markers use documented matriarch-area locations as scouting anchors, rather than claiming exact guaranteed egg drops. Eggs feed the omelet recipe; feathers feed the tailoring Luffa. |
| [Legion rare-fishing baits](https://www.wowhead.com/guide/legion-fishing) | 23 individually identified tradeable baits, including Pearlescent Conch, Rusty Queenfish Brooch, Rotten Fishbone and the second-stage lures. Current item acquisition tables distinguish direct catches, attracted-mob loot and container contents. Vendor alternatives do not make these vendor-only: the corresponding non-vendor acquisition is recorded. |
| Multi-stage baits | Skrog Toenail leads to a murloc and Aromatic Murloc Slime; Funky Sea Snail leads to a Drogbar and Salmon Lure; Moosehorn Hook leads to Silverscale Minnow; Message in a Beer Bottle contains Axefish Lure; Decayed Whale Blubber attracts Ravenous Fly. Sell unused baits rather than the bound achievement fish. Unique limits matter. |
| Fishing transmog | Four tradeable footwear IDs: Deck Sandals, Diver's Chain Boots, Kul'Tiras Marine Issue Boots and Sea Dog Boots. These are chance fishing catches, with no guaranteed random suffix or item level. Existing suitable-water anchors are reused as non-route options. |
| [Big Fountain Goldfish](https://www.wowhead.com/item=138967/big-fountain-goldfish) | Common edible catch from Legion Dalaran waters, including fountains, sewers and Margoss' Retreat. It is a saleable food item, not a cooking ingredient. No unsupported fixed fishing pin is added. |
| Archaeology keystones | [Ancient Suramar Scroll](https://www.wowhead.com/item=130903), [Highmountain Ritual-Stone](https://www.wowhead.com/item=130904) and [Mark of the Deceiver](https://www.wowhead.com/item=130905). Survey active matching-culture sites. The map rotates; fragments and most artifact rewards are bound, so they are not counted as sale products. |
| [Ancient Mana Crystal](https://www.wowhead.com/item=139786/ancient-mana-crystal), [Ancient Mana Gem](https://www.wowhead.com/item=139890/ancient-mana-gem) | These physical items are tradeable; Ancient Mana currency is not. Loot eligible crystal objects/caches and keep the items unused. Historical underwater-trench endpoints at 79,51 and 80,72 are explicitly scouting anchors, with no respawn or yield promise. Ordinary city mana pickups often grant currency directly instead. |
| Roseate/Sallow Pigment | Processed Legion inscription inputs, not new herb farms. Milling is random, so no guaranteed herb-to-pigment composition is invented. Both pigments now expand into their actual housing and glyph uses. |
| Six uncut Argus gems | Labradorite, Argulite, Lightsphene, Chemirine, Hesselian and Florid Malachite. Empyrium prospecting supplies them with random output. These records support jewelcrafting/decor inputs without adding an ore route or a fixed prospecting yield. |
| [Hardened Felglass](https://www.wowhead.com/item=144329/hardened-felglass) | A tradeable processing result, including [Pilfer Through Parts](https://www.wowhead.com/item=225202/pilfer-through-parts), and a Sprocket Container material. Old shoulder-enchant mob farming is not presented as a reliable modern farm. [Sprocket Container reports](https://www.wowhead.com/item=144330/sprocket-container) and [Engineering discussion](https://us.forums.blizzard.com/en/wow/t/how-to-obtain-schematic-chain-skullblasters/1911950) explain the vendor alternative and old level restrictions. No fixed recycling yield is assigned. |
| Existing leather, cloth, fish and meat | Stonehide Leather, Stormscale, Fiendish Leather, Felhide, claws/teeth, Shal'dorei Silk, Lightweave Cloth, the ordinary Legion fish and existing cooking ingredients retain their sourced farms. Non-ore/herb research records explicitly suppress route lines. |

## Housing and bound support

All 23 current decor recipes are composed items, with reverse `housingUses` links on their listed inputs. These cover the fountains/pool, fences/posts, soup pot, containment cell, six inscription furnishings, jeweler's window/assortment, leather fence/posts/tanner's frame, open-air tent, circular rug and Beloved Raptor Plushie.

Fel-Touched Lumber is Warband-bound and cannot itself be auctioned. Its record describes the housing introduction unlock and dynamic marked trees in the Broken Isles/Argus, without inventing permanent lumber nodes. Finished decor is saleable before being used.

The ten other new bound inputs are the five Reaves components and five legendary-crafting quest reagents. Their records identify actual sources and profession/quest restrictions. Some Reaves sources are in older expansion zones even though the inputs belong to Legion recipes. These are support records, not additional AH products. The existing Blood of Sargeras and Primal Sargerite records are likewise explicitly non-auctionable.

## Random output and exclusions

- Darkmoon Card of the Legion's placeholder is excluded. The 32 real named cards have `randomOutput = true` and no deterministic components. The four named Darkmoon trinkets each require their corresponding eight individual cards; no extra deck-opening conversion is invented.
- Vendor-only supplies are excluded from new products/components: Crystal Vial, parchment/vellum, Foxflower Flux, Runic Catgut, Sharp Spritethorn, ordinary Engineering vendor parts, Nethershard Essence and Legion cooking supplies. Three old fireworks are also omitted as purchased supplies from the Reaves fireworks module, rather than introducing an unrelated Classic craft chain. Recipe labels disclose omitted item names and quantities. Existing legacy catalog vendor rows are not part of the new additions.
- Bound rare achievement fish, Drowned Mana and other reputation currencies are excluded as AH products. Fossorial Bile Larva's item binds on pickup; selling a learned and caged pet is a different valuation path, so it is not falsely labeled an auctionable raw item.
- The obsolete Charred Glyph and random/quest transmutation placeholders are excluded. No deterministic output is assigned to milling, prospecting, recycling or random transmute contents.
- Five housing candidates explicitly marked for a future patch in ATT lack a verified current creating recipe in this pass and are excluded. They are archived rather than presented as available crafts.
- This pass did not verify another tradeable Legion blood/mote/primal analogue or a repeatably farmable tradeable Legion clam container. Older-expansion clams and elemental materials are not relabeled as Legion.

## Validation

- Full material loading and focused audits pass under Lua 5.1: 468 new records resolve, recipe inputs exist, quantities are positive, recursive chains have no cycles or excluded purchased supplies, binding is explicit, map pins are bounded and non-route, and housing reverse links resolve.
- Four permanent specifications cover recipe graphs/binding, random cards versus deterministic assembly, current housing quantities and specialty map behavior. The minimal Lua 5.5 fallback data runner reports **109 passed, nine failed**, compared with **105 passed, the same nine failed** before this pass. This runner is not Busted; baseline failures concern older broad research/map assumptions and Classic/Burning Crusade/Wrath/Mists route expectations.
- Manifest validation passes: six manifests and 219 runtime Lua files. Targeted whitespace checks pass. The repository-wide check still has the pre-existing BACKLOG.md trailing blank line.
- Preservation audits compare against starting snapshots: non-Legion catalog rows/index rows are unchanged, and Legion Herbalism.lua and Mining.lua are byte-for-byte unchanged. The lightweight material index refresh is restricted to Legion entries to preserve unrelated pending work.
- No live WoW, Auction House listing or demand/profit test was performed. Sources establish binding/acquisition/composition, not sale velocity or guaranteed income.

## Changed files

- `Data/FarmingItems.lua`: new catalog entries, compositions and bound-reagent labels.
- `Data/MaterialIndex.lua`: lightweight index entries for the new Legion records.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Legion/Miscellaneous.lua`: specialty acquisition, non-route source pins, random cards and bound support.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Legion/Crafting.lua`: research records from the composed catalog.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Legion/Housing.lua`: decor recipes and material-use links.
- `Data/General-Gold-Tracker_Materials/General-Gold-Tracker_Materials.toc` and `MaterialFarmingSpots.lua`: module registration and research version/date.
- `tests/data/farming_data_spec.lua`: module loading and four regression specifications.
- `docs/research/legion-specialty-2026-10-19.md` and `.json`: source notes, recipe evidence, exclusions and validation.
