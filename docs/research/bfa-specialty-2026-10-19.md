# Battle for Azeroth specialty discovery and composed crafting

Researched **2026-10-19** for Retail. This pass adds **682 catalog entries**: **674 saleable products** and **eight required bound support inputs**. The BfA catalog now contains **754 entries**. It records **625 composed recipes**: 622 newly cataloged outputs plus compositions for the three existing bound inputs Expulsom, Hydrocore and Sanguicell. The additions also include 32 individually identified random Darkmoon cards and 28 specialty/support records. There are **22 current housing decor recipes** among the compositions.

Every new catalog row, research record and source pin has `isRoute = false`. Existing non-ore/herb BfA entries are also explicitly non-route. The two BfA herb/ore modules, their supplied imports and their catalog flags are unchanged from the start of this pass. No raw ore, herb, vendor-only product or vendor-only ingredient row was added. Existing herbs and ores remain legitimate ingredients of crafted products.

## Discovery and verification

- The [AllTheThings BfA crafted-item index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/08%20-%20Battle%20for%20Azeroth.lua) and [Retail reagent index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua) supply item identities, profession classification and creating-spell candidates. Ackis recipe lists supply additional candidates. Discovery inspected 1,174 item IDs and 1,219 initial spell IDs, then additional ingredient, enchant and assembly records. Discovery candidates are not automatically accepted as farmable or saleable.
- Current [Wowhead item and spell tooltips](https://nether.wowhead.com/tooltip/item/152668) supply binding, ingredients, recipe rank, batch size and requirements. Live item-page created-by tables fill gaps and retain distinct Alliance/Horde output IDs. Faction variants can share a creating spell that displays the counterpart item: their own created-by tables establish the relationship. One recipe is selected per output, generally its first rank; this is not a claim that it is the cheapest available recipe.
- [Blizzard's housing profession announcement](https://worldofwarcraft.blizzard.com/en-us/news/24247147) establishes the use of legacy materials for decor. Loaded recipe quantities come from current per-spell tooltips rather than older announcement/PTR totals. The [current housing profession guide](https://www.wowhead.com/guide/player-housing/crafting-decor-items) supplies acquisition and binding context.
- The [machine-readable archive](bfa-specialty-2026-10-19.json) preserves selected recipes, full ingredients, omitted supplies, alternative recipes, discovery coverage, specialty details, uncertainty and exclusions. Public item pages, including available comments and replies, were downloaded for specialty-source review and missing-recipe verification. This is not a claim that every comment on every BfA item was reviewed.

## Composed crafting coverage

| Profession | Recorded outputs | Examples |
| --- | ---: | --- |
| Alchemy | 44 | Coastal and Abyssal potions, utility potions, battle potions, flasks, tradeable alchemist stones, and the two bottle furnishings. The two bound dilution conversions are included as support compositions. |
| Blacksmithing | 132 | Monel-Hardened/Stormsteel armor and weapons, faction-specific Combatant equipment, stirrups, hoofplates, skeleton keys, mount shoes, Monelite Reinforced Chassis and decor. |
| Cooking | 31 | Meals, feasts, Heartsbane Hexwurst, Mecha-Bytes, Famine Evaluator and Snack Table, vision foods and the Boralus-Style Lobster Platter. Serving batches are preserved. |
| Enchanting | 57 | Ring/weapon enchants, faction gathering/crafting enchants, utility scrolls, pets, mount equipment and two decor outputs. Vellum must still be supplied to sell enchant scrolls. Includes the existing Expulsom support conversion. |
| Engineering | 39 | Tradeable weapons, gadgets, consumables, pets, toys, portal generators, Super-Charged Engine, Mecha-Mogul Mk2, Xiwyllag ATV assembly and decor. Bound goggles and profession tools are not misclassified as sale products. |
| Inscription | 68 | Inks, glyphs, contracts, Vantus runes, war-scrolls, tomes/codex, offhands, Highborne Compendiums, six furnishings and four deterministic Darkmoon deck assemblies. |
| Jewelcrafting | 40 | Cut gems, jewelry, utility products and two furnishings. Existing uncut gems remain random prospecting outputs rather than deterministic ore conversions. |
| Leatherworking | 131 | Leather/mail equipment, faction variants, Hardened Tempest Hide, Dredged Leather Bladder, drums, barding, utility items and two furnishings. |
| Tailoring | 82 | Faction-specific cloth armor/cloaks, Embroidered Deep Sea Satin, bags, bandages, mount products and two furnishings. |
| Mechagon tinkering support | 1 | Bound S.P.A.R.E. Crate: 250 bound Spare Parts make one crate after the blueprint unlock. The crate is a component of a saleable feast. |

## Distinctive specialty sources

| Group | Acquisition and recorded qualifications |
| --- | --- |
| [Cursed Haunch](https://www.wowhead.com/item=163782/cursed-haunch) | Loot eligible Drustvar beasts. [Betsy](https://www.wowhead.com/npc=124548/betsy) has a sourced 59.93,34.66 marker. Reports also name Gorehorn/hexcrazed beasts and disagree about yield, so no guaranteed rate is assigned. This is meat loot, not the skinning result. |
| [Recipe: Heartsbane Hexwurst](https://www.wowhead.com/item=163833/recipe-heartsbane-hexwurst) | Tradeable recipe dropped by Raal the Gluttonous in Waycrest Manor, including reported Normal drops. Recipe and cooked food have separate catalog entries; learning consumes the recipe. |
| [Gilded Seaweave](https://www.wowhead.com/item=167738/gilded-seaweave) | Nazjatar humanoid cloth, with later assault-zone sources and chance tailor cache output. Source comments identify naga areas at 41,40 and Gorgonian Overlook at 49,39. A separate 59.14,56.60 comment has conflicting replies and is not promoted to a fixed source pin. Existing bundled catalog pins remain additional options. |
| Existing skins, scales, bones, cloth, fish and meats | Coarse/Dredged Leather, Tempest Hide, Shimmerscale/Mistscale/Cragscale, Blood-Stained/Calcified Bone, Tidespray Linen/Deep Sea Satin, regular fish, Midnight Salmon, Nazjatar/assault fish, Rubbery Flank, Moist Fillet and Questionable Meat retain their existing sourced farms and are explicitly non-route. Hardened Tempest Hide and Embroidered Deep Sea Satin are now expandable crafts. |
| [Mechagon recycling parts](https://www.wowhead.com/quest=56168/factory-refurbished) | Machined Gear Assembly, Tempered Plating and Hardened Spring are tradeable Junkwatt Depot drops after the introductory Factory Refurbished quest. Introductory quest-part versions are bound. Keep the saleable parts uncombined. A bundle takes 5 assemblies, 10 plating and 30 springs. Recyclerizer coordinates are area markers, not promised drop locations. These parts can also feed the bound Spare Parts/War Resources path used by decor buyers. |
| [Honeyback jelly](https://www.wowhead.com/guide/honeyback-hive-reputation-bee-mount-rewards) | Thin, Rich and Royal Jelly are saleable. Farming requires an Alliance Honeyback Hive unlock; better deposit outcomes depend on reputation. All 44 published deposit-search coordinates are retained as **unconnected pins**, with no promised live node or measured yield. Goggles, Honey Smasher and bee-event opportunities are explained. Jelly grades are not represented as an unrestricted reversible conversion. |
| [Zandalari Idol](https://www.wowhead.com/item=154989) / [Etched Drust Bone](https://www.wowhead.com/item=154990) | Auctionable archaeology keystones from matching-culture surveys. Dig sites rotate, so no permanent node geometry is invented. Bound fragments and artifact rewards are not counted as sale products. |
| Pigments | Ultramarine, Crimson, Viridescent and Maroon Pigment are processed sale products. Milling has random results; no deterministic herb-to-pigment composition or additional herb farm is introduced. Their inks are composed crafts. |
| [Five tradeable mount drops](https://www.wowhead.com/guide/mount-collecting-battle-for-azeroth) | Goldenmane's Reins, Chewed-On Reins of the Terrified Pack Mule, Reins of a Tamed Bloodfeaster, Captured Dune Scavenger and Great Sea Ray. Documented camp/water markers are scouting anchors. The unused item is saleable; learning it consumes that sale product. No guaranteed kill count or hourly mount yield is recorded. |
| [Battle-Scarred Augment Rune](https://www.wowhead.com/item=160053) | Saleable mission/reward product. War Campaign follower missions vary and are timed, not outdoor repeatable farms. Current level restrictions matter. No historical sale price is imported. |

## Housing and bound support

All 22 verified decor recipes are composed rows, with reverse `housingUses` links on their listed inputs. The current Boralus Bottle Lamp uses three Darkpine Lumber, six Sea Stalk and two Tidespray Linen plus the separately required purchased vial. The current Zandalari Bottle Shipment uses six lumber and one Anchor Weed plus three purchased vials. These differ from the older announcement quantities.

[Darkpine Lumber](https://www.wowhead.com/item=251768/darkpine-lumber) is Warband-bound. It is a dynamic housing resource, not an AH commodity; finished unused decor is saleable. Six other new raw support records cover four bound Mecha-Mogul components, Spare Parts and Energy Cell. The S.P.A.R.E. Crate is the eighth new bound input. The six existing bound BfA records, including Ionized Minnow, are explicitly labeled non-auctionable. None are counted among the 674 saleable additions.

[Hydrocore](https://www.wow-professions.com/guides/bfa-alchemy) no longer directly drops from BfA dungeons after its replacement by Tidalcore. Its research entry now uses the conversion instead of presenting the old shared dungeon markers as a current Hydrocore drop farm. Tidalcore and the other reagent entries retain their relevant existing source records.

## Random output, source anomalies and exclusions

- All 32 real named Darkmoon cards are random possible outputs with no deterministic components. Each of the four Darkmoon Deck trinkets requires its corresponding eight cards. The synthetic Darkmoon Card of War placeholder is excluded. The Xiwyllag ATV combines one crafted engine and one crafted chassis; it is not a separate random mount craft.
- Vendor-only supplies are omitted from new products and recursive component lists: vials, parchment/vellum, threads, fluxes, tanning oil, distilled water, Acacia Powder, ordinary vendor Engineering supplies, BfA cooking supplies, Perfect Preservatives and the purchased Barely Stable Azerite Reactor. Exact names/quantities remain in recipe notes and the archive. Glyph of Lavish Servings also requires Conjured Mana Buns: those are disclosed but excluded from AH components. Displayed costs therefore represent only the retained farmable/crafted portion of each recipe.
- Three tooltip results incorrectly display `(0)` outputs: Aqueous Dilution, Sanguinated Dilution and Light-Step Hoofplates. The first two explicitly describe one-for-one conversions; the third describes creating a single set. Recorded quantities are one, with the source anomaly preserved in the archive.
- Four ATT decor candidates carry future 12.1.5 markers and have no verified creating recipe in this pass: Nomad's Campfire Grill, Nomad's Round Cushion, Nomad's Steel Forge and Closed Vulpera Scroll. They are archived, not added as available crafts.
- Some remaining faction-specific item pages returned HTTP 403; unsupported output/recipe relationships are not fabricated. The archived coverage lists distinguish verified compositions, existing catalog records, random cards/pigments, future/removed candidates and unverified candidates. This pass does not claim every BfA item is covered.
- River Clam Pearl is bind-on-pickup and is excluded as an AH product. The older Abyssal Clam is Cataclysm, not a new BfA clam. Locked boxes, bound currencies and learned/caged-pet valuations are not presented as auctionable raw item products.
- No verified tradeable BfA mote/primal-style elemental was found in this pass. Expulsom, Hydrocore, Tidalcore, Sanguicell and Breath of Bwonsamdi are bound support. Blood-Stained Bone and the distinctive meat/processing/recycling products remain the relevant saleable alternatives.

## Validation

- Full catalog/module loading and the focused audit pass under Lua 5.1. Checks cover new records, binding, positive recipe quantities, recursively resolvable components, cycle absence, excluded supplies, housing reverse links, random cards, map-option pin flags, unchanged herb/ore imports and preservation of unrelated catalog/index records.
- All three new BfA regression tests pass. The minimal Lua 5.5 data-spec runner reports **112 passed, nine failed**, compared with **109 passed and the same nine failed** against the starting snapshots. Those baseline failures concern broad research/map assumptions, one pre-existing missing-catalog item, and older Classic/Burning Crusade/Wrath/Mists route expectations. The fallback runner is not Busted, which is unavailable in this environment.
- Manifest validation passes: six manifests and 222 runtime Lua files. Targeted diff checks pass. Headless Lua checks are not live WoW verification.
- No live Auction House listing, demand, profit, drop-rate or in-game farm validation was performed. Source acquisition/binding does not establish sale velocity or income.

## Changed files

`Data/FarmingItems.lua`, `Data/MaterialIndex.lua`, the Materials catalog TOC/version, three new BfA modules (`Miscellaneous.lua`, `Crafting.lua`, `Housing.lua`), `tests/data/farming_data_spec.lua`, and the two research archive files. Existing BfA profession source modules are preserved, including the herb and mining imports.
