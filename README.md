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

### Minimap / Compact Total
![Minimap and Compact Total Placeholder](https://via.placeholder.com/1000x560?text=Minimap+%2F+Compact+Total)

## 🔧 Commands

- `/gt` — Open main tracker window
- `/gt start` — Start session
- `/gt new` — Force a new session
- `/gt stop` — Stop session
- `/gt options` — Open options panel
- `/gt total` — Toggle compact total window
- `/gt help` — Show command help
- `/gtt` — Toggle compact total window

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
- Minimum item quality
- Highlight threshold
- Notifications on/off
- Auto-start behavior
- Session history on/off
- History rows per page
- Show raw looted gold entries in log
- Track loot source in log
- Window transparency

---

## 📚 TradeSkillMaster (Optional)

TSM is optional, but recommended if you want Auction House pricing.

- If TSM is installed: item values can use market data.
- If TSM is not installed: TSM-based values return `0`, and fallback/vendor values are used where available.

---

## 💾 Saved Data

SavedVariables table:
- `WoWGeneralGoldTrackerDB`

---

## 🛠️ For Issues / Feedback

If you find a bug or want to request a feature, open an issue on the project page and include:
- What happened
- What you expected
- Steps to reproduce
- Any relevant addon settings
