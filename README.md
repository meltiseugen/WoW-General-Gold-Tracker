# General Gold Tracker

**General Gold Tracker** is a lightweight **Retail WoW addon** that helps you see how much gold your current farming session is worth.

It combines:
- 💰 Raw looted gold
- 🛒 Auction House value (via TradeSkillMaster)
- 🧾 Vendor value
- 📈 Session summaries and highlights
- 🗂️ Session history by date and location

---

## ✅ Supported Version

- **World of Warcraft Retail (Mainline)**
- Interface: **120000+**

> This addon is designed for Retail only.

---

## UI skins

Open `/gt options`, then **Appearance** to choose Midnight Classic, Ember Parchment, Quiet Botanical, Quiet Arcane, Field Ledger, or Minimal Voidglass. The skin preview shows your selection; click **Reload UI** to apply it. Midnight Classic remains the default; all artwork is bundled, so TODO-Planner is not required.

---

## 📦 Installation (CurseForge-Friendly)

### Option 1: CurseForge App (recommended)
1. Open the **CurseForge** app.
2. Go to **World of Warcraft → Retail**.
3. Search for **General Gold Tracker**.
4. Click **Install**.

### Option 2: Manual install (ZIP)
1. Download the addon ZIP.
2. Extract it.
3. Move all eight addon folders into:
   `World of Warcraft/_retail_/Interface/AddOns/`
4. Confirm these folders are beside each other:
   - `General-Gold-Tracker`
   - `General-Gold-Tracker_Rares`
   - `General-Gold-Tracker_Instances`
   - `General-Gold-Tracker_Drops`
   - `General-Gold-Tracker_Materials`
   - `General-Gold-Tracker_Farms`
   - `General-Gold-Tracker_TSMRealmData` (optional TSM realm comparisons)
   - `General-Gold-Tracker_MapData` (terrain detail for interactive maps)
5. Fully exit and restart WoW after adding these folders so it discovers the
   bundled addons. `/reload` is sufficient for later file updates once all eight
   folders have been discovered.

### Option 3: Development checkout

With the repository at `Interface/AddOns/General-Gold-Tracker`, run this in
PowerShell from the repository root:

```powershell
.\tools\install_catalog_modules.ps1
```

This links the five bundled catalogs, map data, and optional TSM realm module into adjacent
addon folders so local edits stay in sync. Fully exit and restart WoW after the first installation.
Missing catalog folders prevent Explorer from displaying their data.

---

## 🚀 Quick Start

1. Log into a character.
2. Type `/gt start` to begin a session.
3. Loot normally while farming.
4. Type `/gt` to open the main tracker window.
5. Use `/gt stop` when you’re done.

If you enable auto-start in options, sessions can begin automatically.

---

## 🖼️ Screenshots (Placeholders)

> Replace these with your CurseForge/GitHub image URLs when ready.

### Main Window
![Main Window Screenshot Placeholder](https://via.placeholder.com/1000x560?text=Main+Window+Screenshot)

### Session History
![Session History Screenshot Placeholder](https://via.placeholder.com/1000x560?text=Session+History+Screenshot)

### Welcome and modules

The first time you open `/gt`, choose which Explorer tabs to enable: Favorites, Alts,
Market Watch, Rares, Instances, Drops, Materials, Farms, and Bags. **Use selected
modules** saves your choices. **Skip - enable everything**, the close button, and
Escape all enable every module and finish setup. Setup appears once per account,
including on existing installations after this update.

Change these choices anytime in **Options > Modules**. Changes apply immediately
across characters without a reload. Disabling a module hides its tab and preserves
its saved data; disabling Bags also stops its Auction House popup. The core gold
tracker and session recording remain available. If all modules are disabled,
Explorer provides a shortcut back to Modules. These switches control Explorer
access; installed addon code and shared data services remain loaded.

### Options Panel
Open `/gt options` for a searchable sidebar with **Appearance**, **Sessions & Loot**, **Pricing**, **Bags**, **Alts**, **Maps**, **History & Storage**, **Alerts**, **Logging**, **Advanced**, and **Experimental** pages.

Hover a setting's **?** button or its control for a detailed explanation, a practical example, and its default value. Numeric settings also show their ranges and units. Help remains available through **?** when a setting is disabled and explains what enables it. Dropdown choices, ordering arrows, alert-rule controls, and page resets have contextual help too. Search includes the detailed explanations and examples.

Preferences save automatically and apply across characters. Pages remember their scroll positions, lists support dragging and up/down buttons, and alert rules offer a Test button. Numeric inputs show their units and reject out-of-range values. **Reset this page** requires a second click and restores only that page's preferences; it does not clear saved sessions, farms, or recorded observations. Later market-history maintenance still applies the configured storage limits.

**Pricing** distinguishes the tracker source, Bags default source, and shared missing-price fallback order. Other Explorer windows retain their own source selectors. **History & Storage** separates session records from market-price observations, with an explicit **Unlimited items** switch; retention days and samples per item still apply.

**Logging** controls GGT output in your default chat frame. Its master switch covers all categories, including warnings, command replies, `/gttsm` reports, and the chat part of alerts. Choose startup, sessions, farming scans, navigation, farm edits, history actions, alerts, warnings/errors, and command/action replies separately. Startup and navigation confirmations default off; the other categories default on. Existing master-switch preferences are preserved. Optional timestamps and **Test chat** apply immediately. Chat preferences do not change the tracker's loot log, diagnostics, alert sounds, or other alert displays; messages are not saved as a separate log file.

### Minimap Button
![Minimap Button Placeholder](https://via.placeholder.com/1000x560?text=Minimap+Button)

## 🔧 Commands

- `/gt` — Open main tracker window
- `/gt start` — Start session
- `/gt new` — Force a new session
- `/gt stop` — Stop session
- `/gt options` — Open options panel
- `/gt explorer` — Open farming explorer
- `/gt instances` — Open explorer on dungeon & raid farming
- `/gt rares` — Open explorer on rare farming
- `/gt mats` — Open explorer on materials farming
- `/gt drops` — Open explorer on observed BoE drops
- `/gt help` — Show command help

---

## 🌟 Main Features

- Session-based gold and loot value tracking
- Preferred TSM value source + configurable ordered missing-price fallback chain
- Minimum item quality filter for AH-tracked loot
- Vendor value tracking (separate from AH quality filter)
- Highlight notifications once threshold is reached
- Auto-start options:
  - On first loot
  - On world/instance entry
  - Resume active session after `/reload`
- Optional loot source tracking (`From: Unit/Node/AOE`)
- Session history tools:
  - Search and date, character, and main-location filters
  - Sort by duration, estimated value, or value per hour
  - Loot, Locations, and Breakdown tabs with a shared location/style scope
  - All-loot, auction-valued, vendor-only, and bound-item views
  - Separate recorded visits and recording periods; legacy timing remains clearly labeled
  - Continuous sessions by default, with optional instance or major-location splitting
  - Resume a saved recording without counting the gap or creating duplicate history rows
  - Merge sessions
  - Split sessions by main location

See [Session history behavior and storage](docs/session-history.md) for timing rules and compatibility details.

---

## ⚙️ Options You Can Customize

- Item value source (TSM)
- Reorderable missing-price fallback sources
- Auctionable inventory default value source
- Minimum item quality
- Highlight threshold
- Notifications on/off
- Auto-start behavior
- Session history on/off
- History rows per page
- Show raw looted gold entries in log
- Track loot source in log

---

## 📚 TradeSkillMaster (Optional)

TSM is optional, but recommended if you want Auction House pricing.

- If TSM is installed: item values can use market data.
- If TSM is not installed: TSM-based values return `0`, and fallback/vendor values are used where available.

---

## 💾 Saved Data

SavedVariables table:
- `WoWGeneralGoldTrackerDB`

Session history, saved farming scans, favorites, options, and market/observed drop data are stored account-wide, so every character on the same WoW account can see the same saved data. New session history entries also record which character and realm saved the session.

Eligible uncommon-or-better BoE loot is automatically added to Drops → Session Observed. Scan saved sessions appends older eligible loot without removing existing items or counting the same loot again. Recorded loot coordinates are available through each item's Map button.

Materials learned from session history, refreshed material drop/hour rates, profession/category changes made in the Materials item details, and aggregated map/coordinate observations are written by WoW to SavedVariables. Loot coordinates use a fresh map lookup, short retries, and a recent same-map fallback; unresolved captures are retained as unavailable instead of receiving invented coordinates. To commit that curated data into this repo after logging out or reloading the UI, run:

`lua tools/export_crafting_farming_learned.lua "<WoW>/WTF/Account/<Account>/SavedVariables/General-Gold-Tracker.lua"`

That updates `Data/CraftingFarmingLearned.lua`, which is loaded by the addon on startup. Its `observations` section is a repository-safe research record containing item, map, aggregated source, and coordinate evidence without character names or complete session history. Commit that generated file so other users receive the curated defaults and the observations remain available for later research. Their own in-game category overrides remain local and take precedence over bundled values.

---

## Bundled Data Sources

`Data/General-Gold-Tracker_Rares/RareDrops.lua` is generated from an installed RareScanner copy.

`Data/General-Gold-Tracker_Instances/InstanceDrops.lua` is generated from installed AtlasLoot Enhanced modules:
- Source: https://github.com/nanderson11/AtlasLootEnhanced
- License noted by the source addon: GPL v2 / GPL-2.0

`Data/General-Gold-Tracker_Instances/ATTBoEDrops.lua` is generated from an installed AllTheThings copy:
- Run: `lua tools/generate_att_boe_snapshot.lua`
- Source: https://github.com/DFortun81/AllTheThings
- License noted by the source addon: MIT

The generator scripts are developer tools and are excluded from packaged CurseForge releases.

### Catalog loading and memory

Explorer's large datasets are separate load-on-demand addons: `General-Gold-Tracker_Rares`,
`General-Gold-Tracker_Instances`, `General-Gold-Tracker_Drops`, `General-Gold-Tracker_Materials`,
and `General-Gold-Tracker_Farms`. Install every folder from the release ZIP. A catalog loads
when a feature reads it, including an active farm that needs its route data. Opening Inventory
or Market Watch does not itself require the full material/location catalog. Once loaded, catalogs
remain available until the next UI reload; closing a window releases rebuildable view caches.

For a development checkout directly in `Interface/AddOns`, run
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/install_catalog_modules.ps1`.
This creates sibling junctions to the five catalogs, map data, and the optional TSM realm module without copying the datasets.
Restart WoW completely once after adding them. Release packaging puts the modules in the
same sibling layout through `.pkgmeta`; end users do not need the development script.

### Interactive Alts map

Alts gives the map most of the window, with profession names in a compact roster
and direct links to assigned farms. Search finds characters by name, realm,
profession, farm, role, or zone without changing saved group collapse states.
**Details** opens recorded-location, role, and destination controls on demand.

Maps use fully revealed Blizzard paintings by default, with recorded character
pins, drag panning, and cursor-directed zoom. **Fit zone** / **Fit continent** fits
the selected map; **Center** recenters the saved character position without changing
zoom. **Expand map** hides the roster and summary until **Restore** is clicked.
The continent-group **Map** buttons, character/continent switch, and all four
**Global Map** tabs remain available. Destination-picker artwork is fully revealed too.

**Options > Experimental > Seamless maps** opts into the unfinished stitched-zone
and minimap-terrain rendering. It is off by default and applies immediately.
Switching styles resets existing maps to their initial view and preserves recorded
locations, discoveries, roles, destinations and other Alts features.

With seamless maps enabled, you can explore anywhere on that
continent; zooming out stops at the continent view. **Fit zone** restores the
original zone view. Maps and close-up minimap terrain are always
fully revealed, regardless of what the selected character has explored.
The same transition and terrain renderer serves all supported continents and
worlds, including nested maps and separate physical worlds.

The **Global Map** button at the top of Alts opens a separate, movable and resizable
window with large **Azeroth**, **Outland**, **Draenor**, and **Shadowlands** tabs.
Each world shows its recorded character locations, including low-level, Main, and
Bank alts. Pan and zoom into its continents and zones; **Reset view** returns to
the whole selected world. Characters without usable saved coordinates are counted
as unavailable rather than assigned an approximate marker.

The map component is original GGT code and does not require OpenMap. MapData loads
when an interactive map needs its painted overlays or terrain. Map art remains in the game client and is
copyright Blizzard Entertainment.

### Optional TSM realm prices and diagnostics

Click an armour, weapon, mount, pet, or toy row to open Item Market Details.
The Realm prices view lists captured realms with Min Buyout, Market Value,
Recent Value, Historical Price, and Region sell rate columns. The current realm appears first.
Sell rate uses TSM's `DBRegionSaleRate`, displayed as a percentage. It is the same
regional average across rows, read once per item through TSM's public API without
retaining another dataset. It is not a realm-specific statistic.
Price history remains available in the adjacent view. Missing prices show `--`;
hover a value for its TSM source, snapshot time, and any base-item/species fallback.
Long values use horizontal scrolling and longer realm lists scroll vertically.
The always-available **Realm setup** button opens the setup steps in Help > Value
Sources. The table shows the available realm count, invites additional realms when
only one is captured, and explains how to enable the optional module when needed.

`General Gold Tracker - TSM Realm Prices` captures non-commodity prices from the
realms downloaded by the TSM desktop app. Its source is under
`Data/General-Gold-Tracker_TSMRealmData/` and it ships in the same release as GGT.
Unlike the catalogs, it loads during startup, before AppHelper delivers its data.
It requires GGT and TradeSkillMaster. TSM and AppHelper files are never modified.

Disable this module in WoW's AddOns list and reload to remove its hook, captured
payloads, decoder, and profiling state. GGT's normal current-realm TSM pricing
continues working. Captured data remains in memory only and refreshes at login
or `/reload`, after the desktop app updates its files. There is no background
price polling or full decoded price database.

Diagnostics are explicit and do not produce startup chat messages:

```text
/gttsm status
/gttsm item 6331
/gttsm copy 6331
/gttsm profile on
/gttsm profile off
/gttsm reset
```

Status/copy reports show hook timing, dataset timestamps, retained payload bytes
per realm, payload high-water size, and errors. Capture/query counters and elapsed
time (total, average, maximum) are always available. WoW-attributed module memory
is sampled at login and on diagnostic reports. Payload bytes are not additional
RAM: strings shared with TSM may be attributed to TSM instead of this module.

`profile on` enables native per-call execution/allocation measurements where
supported and samples attributed memory every five seconds; `profile off` cancels
that timer. Only the profiling preference is saved: enable it and `/reload` to
measure startup capture allocations as well. Highest sampled memory is not a true
peak, allocated bytes are cumulative allocation traffic, and timings cover this
module's capture/query work rather than all TSM processing. No global profiler
settings or garbage collections are forced. `reset` clears diagnostic metrics
while retaining prices. `copy` opens a report for Ctrl+A / Ctrl+C.

After editing the material-location catalogs, regenerate the small startup index with
`lua tools/generate_material_index.lua`. Keep `tests/core/catalog_loader_spec.lua` passing
so Market Watch eligibility, metadata and map availability stay aligned with the full dataset.

Startup migrates automatic known-price records to priced materials used by Market Watch. Detailed
market snapshots use a compact saved format that retains their values and respects the
existing retention settings. Session history, favorites, user maps and farms are preserved.
See [the memory change report](docs/MEMORY_OPTIMIZATION.md) for measurements and validation.

Item price graphs collect an observation whenever a valued item list is displayed in
Materials (including the expanded view), Instances, Rares, Drops, Bags, Favorites,
Market Watch, or farm item valuations. Each item saves at most one new sample per elapsed
interval, even when its price has not changed. Configure **Snapshot interval (minutes)**
under **Options > History & Storage > Market-price storage**; the default is 60 minutes.
The previous default limit of 500 tracked items is upgraded to **Max items = 0 (all)**
once so browsing catalogs does not evict other item graphs. Other custom caps remain
unchanged. The existing retention and per-item sample limits still apply; snapshots
already evicted by the old limit cannot be restored.

---

## 🛠️ For Issues / Feedback

If you find a bug or want to request a feature, open an issue on the project page and include:
- What happened
- What you expected
- Steps to reproduce
- Any relevant addon settings
