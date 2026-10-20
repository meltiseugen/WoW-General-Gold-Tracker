# Mists specialty materials, crafted products, and housing

Researched for Retail on **2026-10-19**. This pass adds **938 catalog rows** and upgrades **13 existing rows** with recipe or specialty metadata. There are **909 unique Mists crafted outputs**: **902 auctionable outputs** and **7 bound intermediates required by finished crafts**. The 21 housing recipes are included in those totals. Six legacy ink recipes support the current versions of Mists-era glyphs and retain their own expansion labels.

Every new catalog row, material record, and mapped spot explicitly has `isRoute = false`. No new Ore or Herb gathering entries were added. Their existing rows can be referenced as actual recipe inputs, and the earlier supplied ore/herb routes are preserved. Existing skinning, cloth, meat, and ten-fish catalogs remain available.

## Vendor policy and pricing scope

Per the user's clarification: **exclude vendor-only supplies; keep farmable materials**, including those also stocked by currency/barter vendors. Recipes bought from a trainer or reputation vendor remain eligible when the finished product is crafted rather than vendor-only.

Vials, parchment, coal, wood/staff blanks, settings, gun stocks/triggers, buy-only cooking supplies, Perfect Preservatives, and Orbs of Mystery are omitted from displayed component lists. Full original reagent lists and omitted vendor quantities remain in the [source snapshot](mists-specialty-2026-10-19.json). **Displayed component costs do not include these purchases.** Panther recipe labels specifically remind the player to buy the Orb of Mystery separately. A recipe with no remaining farmable inputs is excluded.

## Discovery and live verification

Recipe IDs were discovered through the [AllTheThings Mists craftables index](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/05%20-%20Mists%20of%20Pandaria.lua), its [Retail reagent index](https://github.com/DFortun81/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua), and Ackis Recipe List profession modules. [Housing Herald](https://housing-herald.com/explore/professions) supplied an independent housing discovery check. These sources are used to discover candidates, not to replace current recipe quantities.

Every selected recipe uses the **live default Retail Wowhead spell tooltip**, with its corresponding item tooltip checked separately for binding. The snapshot stores each spell URL, output ID and batch, component quantity, acquisition text, cooldown, and vendor omission. Item binding is read from the binding field, so wording such as ?enchanting the item causes it to become soulbound? does not incorrectly classify a tradeable scroll or enhancement as bound.

Older housing guides and cached snippets disagree with live tooltips. For example, [Pandaren Alchemist's Kit](https://www.wowhead.com/spell=1263548) currently reports 10 Bamboo Lumber, 8 Green Tea Leaf, 4 Master Mana Potions, 2 Golden Lotus, and a vendor vial. The recorded farmable components use those live values. Master Mana Potion produces two per craft.

## Specialty findings

- **Blood Spirit**, **Haunting Spirit**, and **Spirit of War** cover legacy raid disenchanting. Blood Spirit's vendor alternative does not disqualify its farming source under the clarified policy. Entrance markers reuse the addon's existing [raid entrance research](https://www.wowhead.com/guide/raid-entrances-mists-of-pandaria). These are access pins, not outdoor material spawns. [Spirit of War reports](https://www.wowhead.com/item=102218/spirit-of-war) conflict about ordinary versus tier epics and difficulty; the data preserves that qualification and promises no yield.
- **Spirit of Harmony** now has its ten-Mote conversion and shares the existing Mote source spots. Live Retail tooltips show both as tradeable; the obsolete bind-on-pickup text was corrected. **Small Ethereal Shard**, **Sparkling Shard**, **Serpent's Eye**, and two Pandaria pigments add processing options without inventing fixed disenchant, prospecting, or milling yields. Serpent's Eye consumes ten total shards, including the one used to trigger its conversion.
- Three tradeable [archaeology keystones](https://www.wowhead.com/guide/archaeology-changes-in-mists-of-pandaria-1063) use the active dig-site overlay rather than invented fixed pins. Ten [Tillers vegetables](https://www.wowhead.com/news/mists-of-pandaria-guide-to-the-tillers-205091) have Sunsong Ranch source anchors and daily-farm instructions.
- **Aged Balsamic Vinegar**, **Ancient Pandaren Spices**, and **Aged Mogu'shan Cheese** retain [historical Vale source reports](https://wowrarespawns.blogspot.com/2013/09/vale-of-eternal-blossoms-rares-patch-54.html), with explicit warnings about modern assault phasing and unverified current drop behavior.
- Existing fishing spots now mention opening [bound Sealed Crates](https://www.elsanglin.com/fish/sealed_crate_pandaria.html) for tradeable contents. The crate itself is not an AH listing. No independently auctionable Pandaria clam/openable was invented merely to fill that category.

## Crafted coverage

Counts are unique Mists outputs, including required bound intermediates and housing recipes; they are not profitability or demand estimates.

| Profession | Outputs |
| --- | ---: |
| Alchemy | 34 |
| Blacksmithing | 161 |
| Cooking | 42 |
| Enchanting | 36 |
| Engineering | 44 |
| Inscription | 49 |
| Jewelcrafting | 171 |
| Leatherworking | 245 |
| Mining | 2 |
| Tailoring | 125 |

Coverage includes armor/weapons and reborn weapon chains, crafted PvP appearances, potions/elixirs/flasks, transmutations, cooked foods/banquets, enchantment scrolls and illusion tomes, engineering parts/toys/pets/mounts, glyphs and inscriptions, cut gems and panther mounts, bags, spellthreads, leg armor, inks, cloth, leather, and hides. Existing filter professions are retained when an already-catalogued raw material gains a manufacturing alternative.

## Bound support and exclusions

Imperial Silk, Scroll of Wisdom, Lightning Steel Ingot, Jard's Peculiar Energy Source, Hardened Magnificent Hide, Celestial Cloth, and Balanced Trillium Ingot are bound and are included only as required intermediate inputs. [Bamboo Lumber](https://www.wowhead.com/item=251763/bamboo-lumber) binds to the Warband; it is a housing support input, not an AH product. Fresh Pomfruit, Fresh Lushroom, and Fresh Mangos have two-hour durations and are kept only to explain recipes, with `auctionable = false`; their auctionability is not claimed.

Bound finished products, profession-only Serpent's Eye cuts, research containers, random Darkmoon-card placeholders, old removed-item traps, Skyshards, and unverified pet-caging markets are excluded. Existing BoP pet items are not priced as directly auctionable items. Spirit Dust remains a raw disenchant input, avoiding a cyclic reverse-conversion component model. Alternate manufacture recipes are preserved in the snapshot even where one canonical recipe drives component expansion.

## Validation

The exact-source audit checks all 909 Mists recipe definitions and every added/updated catalog row against the saved facts. Regression checks cover profession breadth, flags, component resolution and cycles, binding distinctions, conversions, map pins, and all 21 housing usage links. Parser and manifest validation are separate from live WoW behavior. Current source pins, drop eligibility, recipe availability, and the rendered UI still require `/reload` verification in Retail.

## Changed files

- `Data/FarmingItems.lua`: researched catalog rows and component chains; existing filter professions retained.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Alchemy.lua`: current Retail Mote/Spirit tradeability guidance.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Fishing.lua`: bound crate guidance on existing fishing sources.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Miscellaneous.lua`: specialty, crop, processing, and support records.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Crafting.lua`: composed research metadata without invented spawn spots.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots/Mists/Housing.lua`: 21 recipe records and material usage links.
- `Data/General-Gold-Tracker_Materials/General-Gold-Tracker_Materials.toc`: load the three new data modules.
- `Data/General-Gold-Tracker_Materials/MaterialFarmingSpots.lua`: increment the data version.
- `tests/data/farming_data_spec.lua`: load modules, add four focused specs, update researched Mists expectations and the required Outland ink count.
- `docs/research/mists-specialty-2026-10-19.json`: recipe/source/quantity/binding evidence.
- `docs/research/mists-specialty-2026-10-19.md`: scope, findings, qualifications, and validation notes.

Unrelated pre-existing worktree changes were preserved.

### Completed automated checks

- Exact source comparison: **909 Mists recipes and 951 added/updated catalog definitions passed**, including output batches, component order/quantities, flags, and binding metadata.
- Four new Mists regression specs plus the existing ore/herb route specs passed in the Lua 5.1 fallback harness. The broader data harness is **97 passed / 9 failed**, versus **92 passed / 10 failed** before this task. All remaining failures were present before this task; no new failing spec names remain.
- All material modules and the data spec parsed under Lua 5.1. Manifest validation passed for **6 manifests / 208 runtime Lua files**. Whitespace checks passed.
- Vendor-only products/reagents were checked against every added/updated row and component list. Earlier Mists raw Ore/Herb catalog lines were preserved exactly.
- The normal Busted suite and live WoW behavior were not run. Historical drop-source qualifications remain visible in source details.
