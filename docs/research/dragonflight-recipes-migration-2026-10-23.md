# Dragonflight recipe scrolls moved to Drops > Recipes - 2026-10-23

Added the Recipes source tab alongside Mounts, Pets and Toys in Drops. Moved the 23 Dragonflight products tagged Dropped Recipe from Materials into that catalog, including recipes, plans, designs, schematics and inscription techniques. The item sold is the unlearned scroll; the crafted output is a separate product.

The dedicated `Data/General-Gold-Tracker_Drops/Recipes.lua` module loads after the generated snapshot. It retains every original item ID, name, acquisition summary, tip and source URL. `RecipeFarms.lua` adds one guide indexed by both item ID and source-record ID for each row. The tab's Map action uses that exact record identity, and recipe rows participate in the existing item-detail realm-price view.

Maps open the Dragon Isles source area (UI map 1978) without fabricated fixed pins. Guides explain the existing fishing-reward acquisition, bound bottle and random recipe contents, and preserve the original sources. [Draconic Recipe in a Bottle](https://www.wowhead.com/item=198438/draconic-recipe-in-a-bottle) documents Dragon Isles fishing and eligible reward-container paths. This relocation preserves the earlier item-specific research rather than claiming a fresh source/binding audit of all 23 recipes. No target recipe, location bonus, drop rate, hourly yield or market price is guaranteed.

Only the Dragonflight records under review move. Materials research registrations and lightweight index entries for those 23 products are removed; other product source lines and recipe component graphs are preserved. The earlier Dragonflight research archive remains historical evidence, with a link to this migration.

The snapshot generator now recognizes the Recipes category and emits its empty base section; the curated module repopulates the products after a refresh. Repeated loads preserve row counts and farm indexes. Recipe rows load through the Drops addon without loading Materials or Farms; guide access loads Farms on demand.

Validation used embedded Lua 5.1 with native UI widgets stubbed:

- Drops UI: 41 passed, including actual selection of Recipes displaying all 23 unique records, always-visible catalog behavior and exact-record Map actions.
- Recipe data/guides: 3 passed, covering Materials absence, unique item/record indexes, repeated loads, and source-area map/detail builders with actions, tips and sources.
- Realm-price details: 16 passed. Existing Dragonflight material data: 7 passed. Catalog cleanup: 3 passed.
- The new recipe lazy-loading check passes. The loader suite has four passed and three existing failures (two missing widget methods and a price-candidate count assumption); all three reproduce with the starting loader. Farm details has 35 passed and three existing valuation-text failures; all three reproduce without the recipe-guide changes.
- An exact before/after comparison confirms all 23 names, summaries, tip lists and source URL lists are preserved. Source changes remove precisely the 23 intended Materials rows/registrations, and regenerating the lightweight index removes precisely their IDs.
- A freshly emitted Drops snapshot followed by the curated module retains all 23 Recipes entries, without duplication on a second load.
- Manifest validation passes for seven manifests and 254 runtime Lua files. Changed-file whitespace checks pass.

Live WoW rendering and fishing remain untested. After `/reload`, open Explorer > Drops > Recipes and check the recipe rows, Map guides, source links and item details.
