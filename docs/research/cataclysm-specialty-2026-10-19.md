# Cataclysm specialty materials and crafting research

Researched 2026-10-19 for Retail. This pass adds **335 catalog entries** and defines **327 unique crafted outputs**, including **20 housing crafts**. Eight already-catalogued outputs gained verified recipe metadata; 319 crafted outputs and 16 specialty/support inputs are new catalog rows. Fifteen of those inputs are tradeable; Ashwood Lumber is a bound support input. Dreamcloth is also bound and appears only as a clearly labeled crafting input.

No additional ore or herb gathering records were added. Existing ore and herb routes remain separate. Existing ore/herb items are referenced when a craft actually consumes them; smelted bars are component-chain intermediates. Every new catalog row, material research record, and mapped spot explicitly has `isRoute = false`.

## Sources and quantity policy

- Recipe components, output batches, item identities, and binding were read from **live Wowhead tooltip endpoints** on the research date. Each recipe has an individual spell URL in the [source snapshot](cataclysm-specialty-2026-10-19.json).
- Housing Herald's [profession list](https://housing-herald.com/explore/professions) helped discover the complete Cataclysm decor set. Its older quantities conflicted with live tooltips. The imported quantities use the live spell tooltips, such as [Gilnean Cauldron](https://www.wowhead.com/spell=1261255), rather than the older list or cached search snippets.
- Components show farmable inputs. Vendor-only vials, thread, dyes, parchment, settings, stock/trigger parts, and Vial of the Sands vendor reagents are omitted from the farming catalog and component lists. **These are not full crafting-cost estimates.** The JSON snapshot retains every original reagent, including the omitted ones, for auditing.
- Output batches matter: Deepstone Oil makes 2 per Albino Cavefish, Handful of Obsidium Bolts makes 3 per craft, and housing budget icons are not output quantities.
- One explicit recipe is selected per output. Dreamcloth uses Dream of Destruction (8 bolts and 4 Chaos Orbs); Pyrium Bar uses smelting. Alternative recipes are retained in the source snapshot. No cheapest-recipe or expected-random-loot valuation is assumed.

## Farmable additions

| Item or group | Acquisition | Notes and evidence |
| --- | --- | --- |
| Abyssal Clam | Vashj'ir naga | [Retail item and comments](https://www.wowhead.com/item=52340). Open for Blood Shrimp, which already has farming coverage. The southern cliff pin is explicitly a historical scouting anchor. Later reports dispute old Uldum Neferset drop tables. |
| Chaos Orb | Cataclysm heroic end bosses | [Retail item](https://www.wowhead.com/item=52078). The example pin is legacy Heroic Vortex Pinnacle; saved boss lockouts differ from trash resets. |
| Living Ember | Firelands bosses | [Retail item](https://www.wowhead.com/item=69237). Tradeable crafting reagent, distinct from bound Eternal Ember. |
| Essence of Destruction | Dragon Soul bosses | [Retail item](https://www.wowhead.com/item=71998). Portal anchor uses Caverns of Time map 75 at 62.2,28.2, as described in the [raid entrance guide](https://www.wowhead.com/guide/raid-entrances-of-cataclysm-6071). |
| Hypnotic Dust, Small Heavenly Shard, Maelstrom Crystal | Disenchant suitable Cataclysm gear | [Maelstrom Crystal sources](https://www.wowhead.com/item=52722). Gear quality, scaled item level, and current disenchant tables matter. Check valuable transmog before disenchanting it. |
| Queen's Garnet, Lightstone, Deepholm Iolite, Lava Coral, Shadow Spinel, Elven Peridot | Dragon Soul currency geodes | [Mote of Darkness](https://warcraft.wiki.gg/wiki/Mote_of_Darkness). Use Normal/Heroic boss currency; the epic color is random. The resulting gems are tradeable; the currency is not an AH item. |
| Ashen Pigment and Burning Embers | Cataclysm milling / AH | [Ashen Pigment](https://www.wowhead.com/item=61979), [Burning Embers](https://www.wowhead.com/item=61980). Processing inputs for inks, not new herb routes or fixed-yield recipes. |

The existing coverage of Savage Leather/Scraps, Pristine Hide, Blackened Dragonscale, Deepsea Scale, Embersilk Cloth, eleven fish, cooking meats, Blood Shrimp, and Volatiles was preserved. Skinning tips now explain opening bound Strange Bloated Stomachs for tradeable Volatiles.

## Crafted outputs

Counts are unique output items, not recipes or fixed profitability claims. Housing crafts are included in these counts.

| Profession | Outputs |
| --- | ---: |
| Alchemy | 37 |
| Blacksmithing | 77 |
| Cooking | 25 |
| Enchanting | 6 |
| Engineering | 22 |
| Inscription | 9 |
| Jewelcrafting | 20 |
| Leatherworking | 67 |
| Mining | 4 |
| Tailoring | 60 |

Coverage includes armor and weapons, bags and specialty containers, leather enhancements, inks, meta gems and transmuted gems, potions/elixirs/flasks, Vial of the Sands, engineering components/toys/pets, cooked fish/meat, and two Cataclysm illusion tomes. Finished items can expand recursively through the existing composed-material UI.

The 20 housing recipes span Alchemy (2), Blacksmithing (2), Enchanting (2), Engineering (2), Inscription (5), Jewelcrafting (2), Leatherworking (3), and Tailoring (2). Their direct reagents have `housingUses` links back to the relevant finished decor. Bound materials are labeled, and unlearned decor is marked tradeable.

## Exclusions and qualifications

- [Strange Bloated Stomach](https://www.wowhead.com/item=67495) is bind-on-pickup. It is guidance on the existing skinning farms, not an auction listing.
- [Dreamcloth](https://www.wowhead.com/item=54440) is bind-on-pickup; [Ashwood Lumber](https://www.wowhead.com/item=251764) binds to the Warband. They are included only because finished crafts require them, with `auctionable = false` and bound category labels.
- Darkfathom Pearl and Flawless Pearl are vendor-quality clam bonuses, not special crafting pearls. They were not added as crafting markets.
- Eternal Ember and other legendary quest reagents are not auctionable substitutes for Living Ember. Later-expansion blood reagents were not relabeled as Cataclysm materials.
- Random Darkmoon-card spell placeholders were excluded from deterministic component pricing. No value is assigned to a particular random card or gem outcome.
- Existing BoP pet drops were not presented as directly auctionable item IDs. Selling a cageable pet is a separate pet-caging workflow.
- Farming source pins are entrance/access/scouting anchors where stated. No rates, gold/hour, market demand, or live WoW drop behavior were fabricated.

## Validation

- All 327 recipe definitions matched the saved live-source components, output quantities, profession, and binding metadata.
- All 335 new catalog entries are sourced, non-route, and outside the Ore/Herb categories. Every component resolves to a catalog item and the new recursive chains are acyclic.
- All 20 housing recipes reference their actual catalog components, with direct-material usage links.
- Five focused Cataclysm data specs passed in a Lua 5.1 compatibility harness. The wider farming-data harness has existing failures also present at HEAD; this pass introduced no additional failing spec names.
- Runtime Lua syntax, manifest coverage, and whitespace checks passed. The full Busted suite and live WoW `/reload` behavior were not run.
