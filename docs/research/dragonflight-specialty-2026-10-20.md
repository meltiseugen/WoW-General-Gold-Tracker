# Dragonflight specialty farms, composed crafts and housing

Researched **2026-10-19–20** for Retail. Added **1,329 catalog entries**: **1,315 saleable products** and **14 explicitly bound support inputs**. Of these, 1,328 entries belong to Dragonflight; the remaining entry is the seasonal Classic Snowball required by a Dragonflight novelty craft. The pass records **1,186 composed products and conversions**, including **25 housing recipes**. It includes **32 named random Darkmoon cards** and **23 fishing-related recipe drops**.

All new catalog and research entries and their map pins use `isRoute = false`. Existing Dragonflight non-ore/herb records are also explicitly non-route. No raw ore or herb row was added, and the previously imported herbalism/mining files and their catalog rows are preserved. The old vendor-only Ohn’ahran Potato row and vendor pins were removed from the loaded catalog. Vendor-only supplies are excluded from the new component graphs.

## Evidence and composition rules

- [ATT’s current Dragonflight crafted-item index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/09%20-%20Crafted%20Items/10%20-%20Dragonflight.lua) and [Retail reagent index](https://github.com/ATTWoWAddon/AllTheThings/blob/master/.contrib/.db/standard/00%20-%20DB/ReagentsDB.Retail.lua) provided 1,837 item candidates and 910 initial spell candidates. Index membership alone is not treated as proof of auctionability, availability, or output quantity.
- Current Retail Wowhead item tooltips establish names and binding. Creating-spell tooltips and readable item-page tables establish full reagent quantities and recipe requirements. [Client spell-effect records](https://wago.tools/db2/SpellEffect), [CraftingData](https://wago.tools/db2/CraftingData), and its item/enchant quality tables independently match every recorded output and baseline batch. Reagent-index counts and the tooltip’s skill-up icon are not mistaken for output batches.
- Quality variants share the verified recipe family. Displayed ingredients refer to base-quality IDs; skill, input quality and specialization determine the achieved output rank. A rank-three output is not guaranteed from the listed base-quality inputs. Multicraft/resourcefulness are not fixed recipe yields.
- For example, Phial of the Eye in the Storm has a baseline batch of two, Elemental Potion of Power five, and Wildercloth Bag one. Dracothyst uses 300 Zaralek Glowspores and 50 Silken Gemdust, with the recorded one-day recharge and charges. Seven Rousing-to-Awakened combinations use ten matching Rousing units per output, including the unit consumed by item use.
- [Blizzard’s housing profession announcement](https://worldofwarcraft.blizzard.com/en-us/news/24247147/professions-unpacked-craft-housing-decor-with-reagents-from-every-era) and the [housing crafting guide](https://www.wowhead.com/guide/player-housing/crafting-decor-items) establish the system. Loaded amounts use current recipe/tooltips and client output data. The [JSON archive](dragonflight-specialty-2026-10-20.json) retains complete ingredients, omitted supplies, output evidence, source URLs and qualifications.

## Composed coverage

| Profession | Recorded products/conversions |
| --- | ---: |
| Alchemy | 129 |
| Blacksmithing | 95 |
| Cooking | 46 |
| Enchanting | 176 |
| Engineering | 168 |
| Inscription | 159 |
| Jewelcrafting | 141 |
| Leatherworking | 142 |
| Skinning | 6 |
| Tailoring | 124 |

Coverage includes potions/phials, incense, Dracothyst and other alchemy reagents; alloys, keys and saleable blacksmithing equipment; enchant scrolls and crafted enchanting materials; engineering parts, tinkers, consumables, tools and toys; inks, missives, glyphs, manuscripts, cosmetics and decks; gems, jewelry and jewelcrafting intermediates; hides/scales, armor kits, drums and leatherworking products; bolts, spellthreads, bags, bandages and tailoring goods; and meals, feasts and cooking intermediates. Bound work-order equipment is not presented as an AH product.

## Specialty discoveries

| Product/family | Acquisition and limits |
| --- | --- |
| [Obsidian Cobraskin](https://www.wowhead.com/item=205413) | Bait-summoned Elusive Magma Cobra at the Zaralek lava pool around 44.05,47.87. Mastery unlock and first eligible daily skinning attempt matter; no guaranteed skin or fixed drop rate. [Blizzard forum reports](https://us.forums.blizzard.com/en/wow/t/obsidian-cobraskin/1592275) corroborate the constrained chance. |
| [Dreaming Antler Fragment](https://www.wowhead.com/item=210456) | Elusive Verdant Gladewarden search area at 57.24,38.44 in the Emerald Dream, using the appropriate bait setup. The antler is not guaranteed. |
| [Auric Fleece](https://www.wowhead.com/item=204092) | Bait-summoned Elusive Auric Argali in the Forbidden Reach; interaction/search positions and conflicting cooldown reports remain qualified. |
| Species-specific skins | Salamanther Scales, Cacophonous Thunderscale, Rockfang Leather, Windsong Plumage, Fire-Infused Hide and Flawless Proto Dragon Scale supplement the existing Crystalspine Fur and Pristine Vorquin Horn. Supported search areas and rare-versus-bulk distinctions are retained. Base leather/scales and rare hide quality families are complete; Resilient Leather 193210 is quality two and 193211 quality three. |
| [Dull Spined Clam](https://www.wowhead.com/item=198395) and [Rainbow Pearl](https://www.wowhead.com/item=198397) | Dragon Isles fishing, with Iskaara open water as a documented search area. Opening yields meat and a chance of a pearl. No deterministic clam-to-pearl recipe, fixed opening return, or guaranteed Perception effect is encoded. |
| Specialty fishing | Magma Thresher lava pools and the renown-15 fishing gear; Prismatic Leaper highland schools and the charm unlock; Elusive Croaking Crab in Forbidden Reach fishing water and eligible lunker loot; Soggy Clump of Darkmoon Cards and tradeable recipe/schematic drops. The bound Draconic Recipe in a Bottle is not listed as an AH product. |
| Creature reagents | Aquatic Maw, Iridescent Plume, Large Sturdy Femur, Mastodon Tusk, Contoured Fowlfeather, bait morsels and Glowing Titan Orb. Existing bear spine, tallstrider sinew, primal wool, Empty Magma Shell and reputation-token records remain available. |
| Lizi materials | Fluorescent Fluid, High-Fiber Leaf and Woolly Mountain Pelt have creature-drop search areas. Buyers need the quest/renown unlocks; the purchased final drink is excluded. |
| Elementals and alchemy | All seven Rousing/Awakened families are represented. Existing earth/fire/air/frost creature farms remain; Order/Ire/Decay requirements are disclosed rather than assigned invented mob pins. Ire has War Mode/instanced-PvP sources. Primal Convergent, Omnium Draconis, Dracothyst and other crafted alchemy reagents have compositions. |
| Later-patch reagents | Zaralek Glowspores include documented fishing and skinning alternatives; Salt Deposit and Lava Beetle include reported lava-fishing side catches. Shadowflame Essence and Dreaming Essence are tradeable raid reagents, with raid-lockout limits. |
| Random processing | Raw pigments, uncut gem quality variants, Fractured Glass, Crumbled Stone and Silken Gemdust remain random processing products without deterministic named-result recipes. Existing gem categories and legacy prospecting-input coordinates are preserved as non-route metadata. |
| Darkmoon cards | All 32 actual named cards are random crafting/fishing products. Four decks have verified eight-card assemblies, including the nonconsecutive Seven of Fire/Frost IDs. Bound upgraded deck boxes are not sale products. |

## Housing and vendor boundaries

All 25 housing products have composed inputs and reverse `housingUses` links. Examples include Draconic Nesting Bed, Valdrakken Market Tent, Draconic Circular Rug, Thaldraszus Telescope, the three dragonflight literature furnishings, Valdrakken containers, food platters, Dragon’s Elixir Bottle, Verdant Valdrakken Vase, Valdrakken Hanging Cauldron, Wingrest Signal Brazier, Five Flights’ Grimoire, Draconic Scribe’s Basin, Tapestry of the Five Flights, Titanic Tyrhold Fountain and Valdrakken Wall Shelf. Three plushie products carry patch-12.1.5 source-index markers and verified current item/creating-spell/reagent data; their in-game learning/availability was not exercised.

[Dragonpine Lumber](https://www.wowhead.com/item=251773) is Warband-bound and appears only as a support input, with no fabricated tree-node pins. Four captured elemental crafting souls and nine dropped Forbidden Reach curio prerequisites are also bound support inputs. All 14 have `auctionable = false` and `supportOnly = true`; finished eligible products can be sold.

Purchased water, cooking supplies, flux, thread, parchment, filigree, stoppers, the plain Serevite Rod, Smudged Lens, Pentagold Seal, Rot Resistant Cauldron, Perfect Preservatives and Duck-Eye Glass Beads are omitted from farmable component lists. Their full ingredient quantities remain in recipe notes and the archive. These compositions therefore do not represent complete gold costs including purchased supplies. Recipes bought from trainers/vendors are allowed; their finished farmable/crafted products are not vendor-only items.

The three entirely purchased-input compositions (Twice-Baked Potato and two vendor-blank-based glyph crafts) are not added. Mettle, knowledge drops, profession bottles and other bound quest/progression objects are not misrepresented as saleable materials. No tradeable Dragonflight blood family was established by this pass; the real Rousing/Awakened and other specialty reagent families are used instead.

## Validation and limits

Lua 5.1 full module loading, unique IDs, binding flags, all 1,186 recursive composition graphs, ingredient resolution, cycle detection, source-sized batches, 25 housing backlinks, random-output boundaries, actual map pin flags, imported herb/ore preservation and unrelated pending-data preservation pass. Source audits independently match output IDs/quality families and batches, full ingredient quantities and vendor omissions.

The three new regression tests pass. The minimal Lua 5.5 fallback runner reports **120 passed / 9 failed**, compared with **117 passed / the same 9 failed** before this pass. Those baseline failures concern broad research/map assumptions, an existing uncataloged material and older route-count expectations. This runner is not Busted. Manifest validation passes with **6 manifests / 228 runtime Lua files**. These are static/headless checks; live WoW and Auction House verification remain unperformed.

Initial item/guide pages and their relevant comments were inspected. Later direct ingredient-page requests returned HTTP 403; unreadable pages were not counted as evidence. Readable Retail tooltips, public client tables and browser research supplied the remaining binding/recipe/vendor checks. No claim is made that every comment on every page was reviewed. No live prices, sale speed, profit, hourly yield or drop-rate measurements were collected.

Changed files: `Data/FarmingItems.lua`, `Data/MaterialIndex.lua`, the Materials catalog TOC and data version, three new Dragonflight modules (`Miscellaneous.lua`, `Crafting.lua`, `Housing.lua`), `tests/data/farming_data_spec.lua`, and these two research archive files. Unrelated pending work is preserved.
