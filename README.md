# WoW General Gold Tracker

Retail-only World of Warcraft addon for tracking session loot value.

It tracks:
- Raw looted gold
- Item value (TSM-based AH pricing)
- Vendor value
- Session highlights
- Session history by location/time

## Requirements

- WoW Retail (Mainline client)
- Interface version: `120000+` (see `.toc`)
- Optional: TradeSkillMaster (TSM) for item market values

If TSM is missing, TSM-based item values will resolve to `0`.

## Installation

1. Download or clone this repository.
2. Place the folder in:
   `World of Warcraft/_retail_/Interface/AddOns/`
3. Ensure folder name is:
   `WoW-General-Gold-Tracker`
4. Restart WoW or `/reload`.

## Slash Commands

- `/gt` - open main tracker window
- `/gt start` - start session
- `/gt new` - force new session
- `/gt stop` - stop session
- `/gt options` - open options
- `/gt total` - toggle small total window
- `/gt help` - command help
- `/gtt` - toggle small total window

## Main Features

- Session-based loot value tracking
- Configurable TSM value source + fallback value source
- Configurable minimum item quality for AH tracking/loot log filtering
- Vendor value tracking (independent from AH quality filter)
- Highlight threshold notifications
- Auto-start options:
  - On first loot
  - On world/instance entry
  - Resume after `/reload`
- Optional loot source tracking (`From: Unit/Node/AOE`)
- Session history:
  - Date filtering
  - Sort by totals
  - Merge sessions
  - Split merged/multi-location sessions by location
  - Location-specific details

## Options (General Tab)

- Item value source (TSM)
- Fallback value source
- Min item quality for AH and loot log
- Highlight threshold
- Notifications toggle
- Auto start on first loot
- Auto start on world/instance entry and reload
- Resume active session after reload
- Enable session history
- History rows per page
- Show raw looted gold entries in log
- Track loot source (From: unit/node/aoe)
- Window transparency

## Data / Saved Variables

Addon data is stored in:
- `WoWGeneralGoldTrackerDB`

## Project Structure

- `Core/`
  - `Namespace.lua` - core addon object, defaults, config helpers
  - `Session.lua` - active session lifecycle
  - `History.lua` - history persistence and transforms
  - `Bootstrap.lua` - events and slash command wiring
- `Tracking/`
  - `Valuation.lua` - item/money valuation + session accounting
  - `LootEvents.lua` - event-level loot orchestration
  - `Loot/LootChatParser.lua` - loot/money chat parsing
  - `Loot/LootSourceService.lua` - loot source detection/cache
- `UI/`
  - `MainWindow.lua` - primary tracker window
  - `OptionsPanel.lua` - settings UI
  - `HistoryWindow.lua` - history UI
  - `History/*.lua` - history models/formatters/services
- `WoW-General-Gold-Tracker.toc` - load order and addon metadata
