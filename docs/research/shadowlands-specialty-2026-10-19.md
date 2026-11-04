# Shadowlands specialty farms, composed crafts and housing

Catalog target exclusions were refreshed on 2026-10-23; removed products are pruned from this archive. Counts below describe the original dated research run. See the [current Materials cleanup and map audit](bfa-missing-map-audit-2026-10-23.md).

Researched **2026-10-19** for Retail. This pass adds **410 catalog entries**: **409 saleable products** and **one required bound housing input**. The Shadowlands catalog now contains **461 items**. It records **347 composed recipes**, including 343 newly cataloged outputs and conversions for four existing materials. There are **23 housing recipes**, **32 named random Darkmoon cards**, and **four random blank cards**.

All new catalog rows, research records and source pins have `isRoute = false`. Existing non-ore/herb Shadowlands materials are also explicitly non-route. The previously imported herbalism and mining files and their catalog rows are unchanged. No raw ore, herb, vendor-only product or vendor-only supply row was added. Crafts may consume the existing ore and herb entries.

## Research and recipe evidence

- The [current ATT Shadowlands craft index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/09%20-%20Shadowlands.lua) and [Retail reagent index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua) provided 452 item candidates and 452 initial spell candidates. Index membership is discovery evidence, not sufficient proof of availability or auctionability.
- Current Retail Wowhead item tooltips supplied names and binding; spell tooltips supplied ingredient quantities, batch sizes, requirements and cooldowns. Enchant scrolls were matched to their creating enchant spells. One verified recipe is loaded per output. Ranked alternatives remain in the [machine-readable archive](shadowlands-specialty-2026-10-19.json); a single base-item row does not represent every possible Runecarving rank or optional upgrade.
- Specialty research used individual Wowhead item pages and their embedded comments, the [Protoform Synthesis guide](https://www.wowhead.com/guide/protoform-synthesis-crafting-system-mounts-pets-zereth-mortis), the [Icy Veins synthesis guide](https://www.icy-veins.com/wow/protoform-synthesis-mount-and-pet-guide), Warcraft Wiki, Korthia guides, fishing guides and mission-table reports. Comments were reviewed for source, coordinates, unlock requirements and conflicting claims. This is not a claim that every comment on every item was reviewed.
- [Blizzard's housing profession announcement](https://worldofwarcraft.blizzard.com/en-us/news/24247147) establishes legacy-material decor crafting. Loaded quantities come from current spell tooltips, alongside the [housing profession guide](https://www.wowhead.com/guide/player-housing/crafting-decor-items), rather than older announcement shopping lists.

## Composed crafting coverage

| Profession | Recorded outputs | Coverage examples |
| --- | ---: | --- |
| Alchemy | 43 | Ground herbs, oils, potions, flasks, Shadestone, burst reagents and two housing crafts. |
| Blacksmithing | 43 | Ceremonious/Shadowsteel equipment, Runecarving base pieces, keys, sharpening/weight stones, Shadowghast Ingots and decor. |
| Enchanting | 43 | Saleable enchant scrolls, enchanted profession materials, shattering conversions and decor. |
| Engineering | 20 | Bolts, abrasives, springs, gear assemblies, consumables, utility products and decor. |
| Inscription | 43 | Inks, missives, glyphs, consumables, deterministic deck assembly and decor. Random cards are counted separately. |
| Jewelcrafting | 35 | Cut gems, jewelry, Runecarving base jewelry, optional reagents and decor. |
| Leatherworking | 62 | Armor, weapons, armor kits, drums, Runecarving base pieces, heavy leather/hide conversions and decor. |
| Tailoring | 36 | Cloth equipment, bags, bandages, Runecarving base pieces and decor. |
| Cooking | 22 | Fish/meat meals, feasts and the Caramel Mint Noodle Dish furnishing. |

Four existing materials gained explicit compositions: Heavy Desolate Leather and Heavy Callous Hide each require ten of the corresponding ordinary material; one Sacred Shard shatters into three Soul Dust, and one Eternal Crystal shatters into three Sacred Shards. These processing paths supplement their existing farming sources.

The loaded Shadowghast Ingot composition is the Blacksmithing recipe, producing two ingots from the four covenant-zone ores. The Alchemy alternative has a daily cooldown and remains documented in the archive. Shadestone retains its own daily-cooldown requirement.

## Specialty discoveries and existing farms

| Product or family | Recorded acquisition and limits |
| --- | --- |
| [17 Protoform lattices](https://www.wowhead.com/guide/protoform-synthesis-crafting-system-mounts-pets-zereth-mortis) | Ambystan, Aurelid, Bufonid, Cervid, Geomental, Helicid, Leporid, Lupine, Poultrid, Proto Avian, Raptora, Scarabid, Tarachnid, Unformed, Vespoid, Viperid and Vombata. Matching creatures or treasures provide the lattice; research unlocks matter. Documented creature areas appear as unconnected search pins. |
| [Korthite Crystal](https://www.wowhead.com/item=186017) | Korthia daily/weekly reward opportunities and eligible treasures. Rewards and eligibility vary; no unlimited kill farm or guaranteed crystal rate is claimed. The crystal is tradeable while its Vestige product is bound. |
| [Shadowlands pigments](https://www.wowhead.com/guide/shadowlands-inscription-profession) | Umbral, Luminous and Tranquil Pigment are random milling products. Their ink crafts are composed; no fixed yield is assigned to an individual pigment. |
| Fishing bait | All six original baits and [Precursor Placoderm Bait](https://www.wowhead.com/item=187712) can be fished as well as purchased. Existing matching-fish water markers are reused. The fishing-pole bait bonus excludes the Zereth Mortis bait; no bait bonus to Strange Goop is assumed. |
| [Twilight Bark](https://www.wowhead.com/item=177061) | A non-ore Phaedrum-deposit byproduct needed by housing crafts. Sources also list limited vendor stock, with later comments reporting stock changes. It is retained because it has a supported farmable source and is not vendor-only. |

The existing Desolate Leather, Callous Hide, Pallid Bone, heavy leathers/hides, Protogenic Pelt, Shrouded Cloth, Lightless Silk, Silken Protofiber, Protoflesh, covenant fish and meats remain available. Existing [Strange Goop](https://www.wowhead.com/item=187662) and [Progenitor Essentia](https://www.wowhead.com/item=187707) sources remain explicitly non-route; Essentia has fishing, treasure and reported skinning opportunities beyond ore/herb gathering.

Lupine comments specifically report **Sopranian Understanding** gating. Helicid markers retain multiple published snail locations; Vespoid records retain worker-group farming areas. Furidian's three key positions are saved as tips. Poultrid nests are dynamic and have no invented fixed pins. Reports of an additional Mawtouched Avian Poultrid drop remain labeled uncertain. Old Thieving Raptora instant-respawn tricks are reported as nerfed and are not encoded as a farming guarantee.

## Housing and component boundaries

All 23 verified decor recipes have recursive components and reverse `housingUses` links on their listed inputs. Current Sintallow Candles uses **five Arden Lumber, three Ground Widowbloom and two Shrouded Cloth**, plus six purchased Sealing Wax disclosed in its recipe notes. Veil-Secured Animacone uses six lumber, two Ground Nightshade, two Twilight Bark and one Essence of Rebirth. These differ from older announcement totals.

[Arden Lumber](https://www.wowhead.com/item=251772) binds to the Warband. It is the only new bound support row and is labeled non-auctionable; the unused finished furnishings are sale products. Harvesting trees is dynamic, so no permanent lumber-node geometry is fabricated.

Purchased supplies are omitted from catalog additions and recursive farmable-input lists: water, dye, cooking supplies, settings, parchment/vellum, thread, vials, flux, Orboreal Shards, profession supply reagents, Empty Kettle and Perfect Preservatives. Their exact names and quantities remain in recipe notes and the full archive. Displayed component costs therefore cover the retained farmable/crafted portion, not a complete literal recipe cost including purchased supplies.

## Exclusions and uncertainty

- [Genesis Mote](https://www.wowhead.com/item=188957) is Warband-bound, not a tradeable mote/primal-style commodity. Synthesis mounts, schematics, glimmers and other bound parts are not presented as raw AH products. Learned-and-caged pet sale values require a separate species-based system.
- Gaunt Sinew and obsolete zone-leather names persist in old guides. [Warcraft Wiki marks Gaunt Sinew as beta-only](https://warcraft.wiki.gg/wiki/Gaunt_Sinew); no unsupported farm or recipe was added. Desolate Leather Scraps and Callous Hide Scraps remain unverified discovery candidates rather than asserted current farm targets.
- Eternal Flask is the conjured cauldron result. Eternal Cauldron, Spiritual Alchemy Stone and bound engineering goggles are not added as sale products. No dedicated tradeable Shadowlands elemental mote/primal family or new openable clam product was established by this pass.
- Darkmoon Card of Death has random outputs. The 32 named cards and four blank cards have no deterministic named-card recipe; the four deck trinkets use their matching eight cards. Placeholder random-card items are excluded.
- Five source-index housing candidates have future patch markers and no verified current creating recipe in this pass: Hanging Argunite Lamp, Anima-Powered Anvil, Fae Moonbough Scroll, Levitating Lich Library and Venthyr Alchemy Rack. They are archived rather than presented as available crafts.
- Comfortable Rider's Barding already belongs to the BfA catalog and was preserved there, despite also appearing in the Shadowlands source index.
- No live Auction House prices, demand, sale velocity, profit, hourly yield or in-game farm measurements were collected. Binding and recipe evidence do not establish sale speed or income.

## Validation and changed files

The Lua 5.1 audit passes full module loading, all new records and binding flags, 347 recursive composition graphs, ingredient resolution, cycle detection, output batches, 23 housing reverse links, 36 random-card records, actual map-option pin flags, and preservation of unrelated catalog/index data and the herb/ore imports. Shadowlands source pins now carry explicit map IDs, including copied Zereth Mortis fishing-water markers.

All three new regression tests pass. The minimal Lua 5.5 data-spec runner reports **117 passed and nine failed**, compared with **114 passed and the same nine failed** against starting snapshots. Those baseline failures concern broad research/map assumptions, an existing uncataloged item and older Classic/Burning Crusade/Wrath/Mists route expectations. The fallback runner is not Busted. Manifest validation passes with six manifests and 225 runtime Lua files; changed Lua syntax and diff checks pass. These checks are not live WoW verification.

Changed files: `Data/FarmingItems.lua`, `Data/MaterialIndex.lua`, the Materials catalog TOC/version, three new Shadowlands modules (`Miscellaneous.lua`, `Crafting.lua`, `Housing.lua`), `tests/data/farming_data_spec.lua`, and these two research archive files. Unrelated pending work is preserved.
