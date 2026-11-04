# The War Within specialty materials, compositions and housing

Researched **2026-10-20** for Retail. This pass adds **1,045 catalog entries**: **1,043 saleable products** and **two explicitly bound support ingredients**. The War Within catalog now has **1,143 entries**, including its previously imported ore and herb routes.

There are **941 composed product/quality rows from 481 creating spells**, including **24 housing recipes**, plus **122 specialty source records** covering new and existing materials. Counts include distinct quality IDs; they are not claims of 941 distinct profession recipe unlocks. All additions have `isRoute = false`. No raw ore or herb was added. Existing ore/herb catalog rows and their imported route files are preserved.

The [machine-readable research archive](war-within-specialty-2026-10-20.json) records selected recipes, ingredient quantities, output batches, quality families, binding, omitted purchased supplies, specialty sources, comment IDs, exclusions and source URLs.

## Evidence and coverage

- Discovery used the [current ATT War Within craft index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/11%20-%20The%20War%20Within.lua) and its [Retail reagent index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua). The expansion index supplied 1,471 item candidates. Index membership alone was not treated as proof of binding, availability or recipe yield.
- Current Retail Wowhead item tooltips supplied identity and binding; spell tooltips supplied fixed ingredient quantities and recipe requirements. [Client spell effects](https://wago.tools/db2/SpellEffect), [CraftingData](https://wago.tools/db2/CraftingData) and its item/enchant quality tables verified creating spells, output identity and baseline batch sizes. Quality outputs use base-quality ingredient references; skill, ingredient quality, specialization and concentration determine the rank actually produced.
- The [Skinning overview](https://www.wowhead.com/guide/the-war-within/professions/skinning-overview), individual item acquisition tables and comments, [Method's skinning farms](https://www.method.gg/guides/stormcharged-leather-farms-in-the-war-within), [Method's cloth/card farms](https://www.method.gg/guides/weavercloth-and-darkmoon-card-farm-in-the-war-within), fishing guides and profession overviews supplied source evidence. Available embedded comments were captured and relevant source/limit reports reviewed; this is not a claim that every paginated comment and reply was read.
- Housing was checked against [Blizzard's profession announcement](https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era), the [housing crafting guide](https://www.wowhead.com/guide/player-housing/crafting-decor-items), and current creating-spell ingredients. Older announcement shopping lists do not override the verified recipe quantities.

## Specialty discoveries

| Product or family | Acquisition and qualifications |
| --- | --- |
| [Bottled Storm](https://www.wowhead.com/item=218338) and [Burning Cinderbee Setae](https://www.wowhead.com/item=218339) | Species-specific skinning from storm creatures and cinderbees. Reports identify the Cinderwold/Meadery/Rambleshire area; the bee search marker is 70.0, 43.6 on Isle of Dorn. Existing storm-wolf search markers are reused. |
| [Superb Beast Fang](https://www.wowhead.com/item=219013) | Skin the elusive Slatefang summoned with Supreme Beast Lure. A later comment corrects the post-11.1 Ringing Deeps marker to **59.0, 51.0**; the older 62-63 X positions are historical. Reports require Skinning and level 72+, with 40 Trained Tracker points to create the lure. Daily/alt eligibility reports conflict and remain qualified. |
| [Undermine Clam](https://www.wowhead.com/item=235846) and [Undermine Clam Meat](https://www.wowhead.com/item=235845) | Both are tradeable. Fishing reports identify Blackwater Marina at **64.2, 10.7**. Comments report 1-3 meat per clam, with junk and variable catch rates. No guaranteed conversion or catch rate is encoded. The meat feeds the new Authentic Undermine Clam Chowder. |
| Cinderbee Belly and Hot Honeycomb | Raw meat plus a chance-based finishing-reagent byproduct from cooking the belly. Raw bee drop reports are also retained; no fixed honeycomb rate is assigned. |
| Gloomfathom Hide, Ringing Deeps Ingot, Vial of Kaheti Oils and Viridian Charmcap | Tradeable delve/container rewards with exchange alternatives. **Gloomfathom Hide is not a normal skinning hide.** Older delve-specific and Disturbed Earth reports are qualified because reward sources changed and later comments conflict. |
| [Vicious Bloodstone](https://www.wowhead.com/item=215236) | PvP reward opportunities and an Honor purchase alternative; it is not vendor-only. Reward eligibility, season and chance remain explicit. |
| [Forged Combatant's Heraldry](https://www.wowhead.com/item=210221) | Tradeable PvP material with reward sources. Its current reagent-for table verifies eligibility for all **58 Algari Competitor recipes**. Their required heraldry quantities are retained using this item as the recorded baseline choice. Other accepted heraldry may have different binding, season availability and effects. |
| [Manaforged Instrument](https://www.wowhead.com/item=249218) | Rare Forgeweaver Araz reagent from Manaforge Omega; comments also report LFR. Raid access and loot lockouts apply. |
| Pummeler parts, Bountiful Bolts and refurbished tinkers | Engineering salvage and pilfering products. The costly Pummeler parts, including Pummel Permit, have vendor alternatives but also supported processing sources, so they are retained. Specializations matter; there is no fixed pilfering return or profit assumption. |
| Cloth, thread, pigments and crushed gemstones | All three current Weavercloth/Duskweave/Dawnweave ranks are represented. Unraveling, milling and crushing products have source descriptions without fabricated deterministic yields. Processed Chopped Mycobloom and pigments are ingredients, not new raw-herb entries. |
| Darkmoon cards and fishing appearances | 32 named cards remain random outputs; the four deck assemblies each consume their matching eight cards. Twelve verified fishing appearance items are sale products while unused. Equipping/learning can bind them; no transmog sale rate is assumed. |

Existing leathers, hides, carapaces, chitin, bones, fish and meats remain available. Missing meat source records are filled in. Refulgent Crystal quality IDs are corrected to **219952 / 219954 / 219955**; invalid 219953 is removed. Existing Cursed Ghoulfish is labeled non-auctionable.

No standalone tradeable TWW mote/primal family was established by this pass. The Alchemy transmutagen reagents bind on pickup; Blasphemite and the separate Writhing Transmutagen companion item are sale products. Writhing Sample and Viridescent Spores are recorded as secondary, non-herb recipe reagents rather than invented creature blood farms.

## Composed products

| Profession | Product/quality rows | Examples |
| --- | ---: | --- |
| Alchemy | 83 | Potions, flasks, phials, horticulture and finishing reagents, and decor. |
| Blacksmithing | 74 | All four alloy families, equipment, profession tools, finishing products and decor. |
| Enchanting | 241 | Saleable scroll quality variants, oils, illusions and decor. Purchased vellum is disclosed separately. |
| Engineering | 101 | Components, consumables, equipment, devices, mounts and decor. |
| Inscription | 116 | Inks, ciphers, missives, contracts, sigils, equipment, four deterministic deck assemblies and decor. |
| Jewelcrafting | 119 | Cut gems, settings, vials, lenses, finishing materials, jewelry and decor. |
| Leatherworking | 82 | Armor, kits, bindings, profession equipment and decor. |
| Tailoring | 72 | Bolts, cloth equipment, bags, spellthreads, finishing reagents and decor. |
| Cooking | 48 | Meals, feasts, prepared foods and four furnishings. Client baseline servings are recorded; actual servings vary with skill and multicraft. |
| Skinning lure crafts | 5 | The verified saleable lure products; bound creature lures are not listed as AH goods. |

Variable salvage outputs such as thread, Fresh Fillet, prepared meat, pigments and individual named cards do not receive invented fixed compositions. Fine Egg Powder and Coagulated Yolk are processed products from purchased eggs, labeled accordingly; raw vendor eggs are excluded. The fixed chains stop at these variable intermediates rather than assuming an average yield.

## Housing and exclusions

All 24 decor recipes have their retained ingredient chains and reverse `housingUses` links. Examples include Boulder Springs Hot Tub, Nerubian Alchemist's Retort, Dornogal Bookcase, Algari Fence/Fencepost, Gundargaz Candelabra, Dornogal Framed Rug, Undermine Bean Bag Chair and four Cooking furnishings.

[Dornic Fir Lumber](https://www.wowhead.com/item=248012) and [Pile of Rusted Scrap](https://www.wowhead.com/item=219150) are the two new bound support rows. They are explicitly `auctionable = false` and `supportOnly = true`; neither is an AH product. Lumber tree spawns remain dynamic without fabricated permanent coordinates.

Purchased-only supplies are excluded from additions and fixed component lists: Echoing Flux, Mosswool Thread, Adorning Ribbon, cooking supplies, parchment, freshwater, Frayed Wiring, Junk Bucket, purchased cauldrons, Perfect Preservatives and other recorded supply items. Their quantities remain in recipe notes and the archive. **The displayed component cost covers retained farmable/crafted ingredients, not the full purchased-supply cost.** Recipe-vendor unlocks are still recorded; buying a recipe does not make its finished product vendor-only.

Bound gear/crests, conjured Fleeting consumables, profession knowledge drops, the bound Bizarrely Shaped Stomach and ability-proxy items are not new AH products. Shadowblind Grouper lacks sufficient current acquisition evidence here and was not added. A discovered Gloaming Alloy candidate was rejected because its recipe belongs to **Midnight**, outside this pass's expansion scope.

## Validation and files

- Lua 5.1 focused audit: full module load; unique IDs; binding; all 941 composed product rows; recursive ingredient resolution and cycle detection; output batches; 24 housing backlinks; 58 heraldry slots; random-output boundaries; source metadata; actual map options/pins; unchanged ore/herb route files and catalog rows; unrelated catalog/index preservation.
- Independent source audit: creating-spell identity, client quality families, baseline batches, original fixed ingredient quantities and disclosed vendor exclusions.
- Three new data regressions pass. The minimal Lua fallback data-spec runner reports **123 passed / nine failed**, compared with **120 passed / the same nine failing test categories** before this pass. Those existing failures concern broad source/map coverage and older expansion route-count assumptions; they are not described as a clean full-suite result. Formal Busted was unavailable.
- Manifest validation and Lua compilation pass. Live WoW `/reload`, crafting UI checks, farm measurements and AH prices/demand were not tested.

Changed runtime files: `Data/FarmingItems.lua`, `Data/MaterialIndex.lua`, the Materials manifest and metadata, `WarWithin/Enchanting.lua`, and new `WarWithin/Miscellaneous.lua`, `WarWithin/Crafting.lua`, `WarWithin/Housing.lua`. Tests and this research archive are included. Imported War Within Herbalism and Mining files are unchanged by this pass.
