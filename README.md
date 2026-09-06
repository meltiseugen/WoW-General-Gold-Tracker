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

## 📦 Installation (CurseForge-Friendly)

### Option 1: CurseForge App (recommended)
1. Open the **CurseForge** app.
2. Go to **World of Warcraft → Retail**.
3. Search for **General Gold Tracker**.
4. Click **Install**.

### Option 2: Manual install (ZIP)
1. Download the addon ZIP.
2. Extract it.
3. Move the folder into:
   `World of Warcraft/_retail_/Interface/AddOns/`
4. Confirm the folder name is:
   `WoW-General-Gold-Tracker`
5. Launch WoW (or type `/reload` in-game).

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

### Options Panel
![Options Panel Screenshot Placeholder](https://via.placeholder.com/1000x560?text=Options+Panel+Screenshot)

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
- TSM value source + configurable fallback pricing source
- Minimum item quality filter for AH-tracked loot
- Vendor value tracking (separate from AH quality filter)
- Highlight notifications once threshold is reached
- Auto-start options:
  - On first loot
  - On world/instance entry
  - Resume active session after `/reload`
- Optional loot source tracking (`From: Unit/Node/AOE`)
- Session history tools:
  - Date filtering
  - Sort by totals
  - Merge sessions
  - Split merged sessions by location
  - Location-specific details

---

## ⚙️ Options You Can Customize

- Item value source (TSM)
- Fallback value source
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

Materials learned from session history and refreshed material drop/hour rates are written by WoW to SavedVariables. To commit those learned material rates into this repo after logging out or reloading the UI, run:

`lua tools/export_crafting_farming_learned.lua "<WoW>/WTF/Account/<Account>/SavedVariables/General-Gold-Tracker.lua"`

That updates `Data/CraftingFarmingLearned.lua`, which is loaded by the addon on startup.

---

## Bundled Data Sources

`Data/RareDrops.lua` is generated from an installed RareScanner copy.

`Data/InstanceDrops.lua` is generated from installed AtlasLoot Enhanced modules:
- Source: https://github.com/nanderson11/AtlasLootEnhanced
- License noted by the source addon: GPL v2 / GPL-2.0

`Data/ATTBoEDrops.lua` is generated from an installed AllTheThings copy:
- Run: `lua tools/generate_att_boe_snapshot.lua`
- Source: https://github.com/DFortun81/AllTheThings
- License noted by the source addon: MIT

The generator scripts are developer tools and are excluded from packaged CurseForge releases.

---

## 🛠️ For Issues / Feedback

If you find a bug or want to request a feature, open an issue on the project page and include:
- What happened
- What you expected
- Steps to reproduce
- Any relevant addon settings
