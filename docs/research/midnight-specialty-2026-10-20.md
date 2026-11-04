# Midnight specialty materials, profession crafts and housing

Researched 20 October 2026. Scope: current Retail Midnight through Patch 12.1.5 and the active Hallow's End event. No new raw ore or herb products are added. Existing ore/herb records remain available as recipe inputs and retain their imported paths.

## Catalog coverage

- **886 new catalog entries:** 881 saleable products and five explicitly bound crafting-support inputs.
- **64 existing Midnight entries updated.** All 950 researched records have `isRoute = false`, including every coordinate-backed spot after bundled catalog loading.
- **785 composed outputs** have verified item identities, baseline batch quantities, exact ingredient quantities, source spell links and quality metadata where applicable.
- **78 saleable housing crafts** have component lists and reverse `housingUses` links.
- **165 specialty records** cover raw drops, processing outcomes, fishing rewards and the five bound prerequisites.
- The lightweight index gains 887 entries: the 886 new products/support records plus the previously pending Aetherlume record. Unrelated pending index work is preserved.

| Profession | Composed outputs |
| --- | ---: |
| Alchemy | 62 |
| Blacksmithing | 71 |
| Cooking | 46 |
| Enchanting | 166 |
| Engineering | 88 |
| Fishing | 10 |
| Inscription | 90 |
| Jewelcrafting | 108 |
| Leatherworking | 79 |
| Tailoring | 65 |

Counts include distinct item IDs for supported quality variants. They are not counts of unique recipe spells. Housing recipes are included in profession totals.

## Farming and processing discoveries

- **Skins and leather:** Void-Tempered Leather, Scales, Hide and Plating, including the missing Hide quality; Fantastic Fur, Carving Canine and Peerless Plumage with specialization requirements; Majestic Claw, Hide and Fin with documented lure placements and eligibility notes. Species-specific advice comes from [Method's farming guide](https://www.method.gg/guides/where-to-farm-fantastic-fur-peerless-plumage-and-carving-canine) and [lure location guide](https://www.method.gg/guides/midnight-majestic-beast-lure-locations). Launch-era low-drop reports are dated observations, not assumed current bugs.
- **Cloth:** Bright Linen, Sunfire Silk and Arcanoweave. The specialty cloth records retain their unlock requirements and sourced Shadowguard Point and Grudge Pit entrances. Farming suggestions are based on [Method's cloth guide](https://www.method.gg/guides/best-bright-linen-cloth-farming-locations); no hourly yield is encoded.
- **Fish and unusual fishing rewards:** launch fish plus Coiled Isle catches, fishing-line fragments and their exact combination chains, fishing lures, unbound cosmetics and individual tradeable fishing recipe drops. The containing Thalassian Recipe in a Bottle is Warband-bound and is excluded as an AH product. [Fishing guide](https://www.wow-professions.com/guides/wow-fishing-leveling-guide), [bottle acquisition and comments](https://www.wowhead.com/item=278329), and the [profession index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/12%20-%20Midnight.lua) distinguish its contents from the container.
- **Recycled and processed reagents:** Aetherlume, Evercore, Glimmering Gemdust, additional gem quality IDs, pigments and Thalassian Fillet. Random processing does not receive a fabricated deterministic ingredient ratio. [Engineering](https://www.wow-professions.com/midnight/engineering-guide), [Jewelcrafting](https://www.wow-professions.com/midnight/jewelcrafting-guide) and [Inscription](https://www.wow-professions.com/midnight/inscription-guide) guides supplement item tooltips and player-reported recycling observations.
- **Elemental and seasonal materials:** the four mote families gain their exact Alchemy transmute compositions and cooldown/charge notes. Neutralized Venom Clot and Cursebound Globe retain their Coiled Isle curse-window sources and reported skinning alternative. They are specialty byproducts, not new raw ore/herb entries. [Alchemy guide](https://www.wow-professions.com/midnight/alchemy-guide), [Patch 12.1 profession changes](https://www.wow-professions.com/news/midnight-patch-12-1-knowledge-point-reset), and [Coiled Isle gathering guide](https://www.method.gg/guides/farming-routes-for-neutralized-venom-clot-and-cursebound-globes-in-wow-midnight).
- **PvP and card materials:** Infused Heliotrope and Galactic Combatant's Heraldry have non-vendor PvP reward sources documented in current item tooltips. All 32 Midnight Darkmoon cards and four exact eight-card deck assemblies are represented. Competitor recipes retain the required heraldry quantity and use tradeable Season 1 Galactic Combatant's Heraldry as a documented eligible baseline; other accepted seasonal heraldry can differ.

No sufficiently verified auctionable Midnight clam/container farm was found in this pass. Older-expansion clams, bound treasure currencies and unverified rewards were not substituted.

## Crafting and housing evidence

Candidate discovery used the [AllTheThings Midnight craft index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/12%20-%20Midnight.lua), its [reagent database](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua), profession guides, recipe-teaching item tooltips and exact client spell-name lookups. Every retained composition was then checked against current Wowhead recipe tooltips and [client SpellEffect records](https://wago.tools/db2/SpellEffect), with CraftingData and quality tables linking each output item ID to its recipe. The companion JSON stores the exact spell URL, client batch URL, quantities, quality family and omitted vendor inputs for every recipe.

Recipe source labels preserve trainer, specialization, vendor-unlock, fishing, discovery and cooldown/charge information. A recipe sold by a vendor does not make its crafted output vendor-only. [Blizzard's housing profession overview](https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era) explains the role of both current and older professions; previously researched older-expansion housing catalogs remain unchanged.

The housing discovery index contains 84 IDs. Of those, 78 are verified saleable crafts; four current outputs bind on pickup and two IDs lack current item tooltips. Those six were not added as saleable housing products. The [official 12.1.5 notes](https://worldofwarcraft.blizzard.com/en-us/news/24304162/) and the updated [Hallow's End guide](https://www.wowhead.com/guide/world-events/holidays/hallows-end) confirm current event coverage. Spidery Witch Hat and Apple Bobbing Bucket are included with exact compositions, seasonal recipe unlocks and required bound holiday ingredients.

## Exclusions and interpretation

Seventeen vendor-only inputs are omitted from new catalog products and component trees: Enchanting Vellum, Cooking Spirits, Thalassian Herbs, A Big Ol' Stick of Butter, Mana-Wyrm Essence, Ripened Vegetable Assortment, Pouch of Spices, Tavern Fixings, Luminant Flux, plain Refulgent Copper Rod, Fused Vitality, Lexicologist's Vellum, Thalassian Songwater, Silverleaf Thread, Embroidery Floss, Malleable Wireframe and Pile of Junk. Required purchased quantities are disclosed in recipe notes; displayed components alone are not the complete crafting cost.

Sunglass Vials are retained because Jewelcrafting provides a verified crafting source in addition to vendors. Infused Heliotrope and Galactic Combatant's Heraldry are retained because PvP activities are documented alternative sources.

**Thalassian Lumber**, **Stabilized Derivate**, **Tricky Treat**, **Drustvar Choc-O-Drops** and **Duskwood Caramel** are bound. All five have `auctionable = false` and `supportOnly = true`; they explain required inputs of saleable crafts and are not represented as AH farming targets. The holiday ingredients are obtainable through event activities, neighborhood rewards and candy buckets rather than being vendor-only supplies. Other bound finished gear, conjured/fleeting outputs, invalid IDs and vendor-only supplies are excluded.

No new income, sale rate, drop percentage or guaranteed random-processing yield is inferred. Source markers are search areas or documented lure placements. Some item HTML pages returned HTTP 403; current tooltip responses and client tables supply the composition evidence instead.

## Validation

Passed the focused Lua 5.1 audit: all 785 compositions, exact tooltip ingredients and required heraldry slots, output identity and baseline batch checks, vendor omissions, bound-input disclosures, all 165 specialty records, all 78 housing recipes and reverse material links, and all 950 item/spot route flags after complete module loading.

The original ore/herb import files and route metadata, unrelated expansion records, unrelated catalog lines and pending index entries were preserved. All 235 runtime Lua files compile, and addon validation passes for six manifests. Composed-row expansion already guards cyclic transmute ancestry in the existing UI.

The full Busted suite was unavailable in this environment. These checks do not establish in-game behavior, current market demand or a completed AH sale. Live `/reload` verification remains outstanding.

Implementation: `Data/FarmingItems.lua`, `Data/MaterialIndex.lua`, the Materials manifest and data version, new Midnight `Miscellaneous.lua`, `Crafting.lua`, `Housing.lua` and post-catalog `Finalize.lua`, plus the existing data-spec module load list. The companion [JSON evidence file](midnight-specialty-2026-10-20.json) contains the detailed inventory and source records.
