# In-game help guide

Open the main tracker's **?** button for **Help & gold guide**. It covers 19
topics across getting started, Explorer, making gold, and reference material.
Search matches all entered words against topic names, summaries, keywords,
section headings, and full text. Matching topics appear in the sidebar; selecting
one shows its complete article. Clear or Escape in the search field restores the
topic selected before searching.

The sidebar and article scroll independently. Reading positions are retained per
topic while the UI is loaded, including when closing and reopening the guide.
An explicit topic entry, including the realm-prices setup shortcut, clears search
and opens that topic at the top. Positions and search are not SavedVariables.

Content lives in `UI/HelpContent.lua`; rendering lives in `UI/HelpWindow.lua`.
Opening help reads small text definitions and pricing preferences only. It does
not load catalogs, scan bags, fetch item prices, or start navigation/tracking.
The text remains available when Explorer modules are disabled.

The guide covers all nine Explorer modules, shared table controls, session
tracking and history, price sources and fallback ordering, realm setup, farm
methods and sharing, route confidence and navigation, options, saved data,
diagnostics, and commands. Gold advice emphasizes small trials, realized sale
proceeds, costs, stock limits, and dedicated bank characters. It does not promise
an hourly return or present GGT as an account-wide inventory or sales ledger.

## Research basis

Addon behavior was checked against the current runtime code and the existing
session-history, farms-workspace, and farm-sharing documentation. Game-system
references checked on 2026-10-26:

- [Blizzard: Get the Band Together for Warbands](https://news.blizzard.com/en-gb/article/24115313/get-the-band-together-for-warbands)
  supports sharing eligible items and gold through the Warband Bank. Transfer
  eligibility and auction eligibility are distinct; inspect binding in game.
- [Blizzard: Shadowlands 9.2.7 Update Notes](https://news.blizzard.com/en-gb/article/23833174/shadowlands-9-2-7-update-notesnow-live)
  documents region-wide commodity auctions in Retail. The guide does not suggest
  realm-hopping for a different commodity price pool.

General farming and bank-alt routines are practical suggestions, not measured
profit claims or an endorsement of a particular current farm.

## Validation boundary

Focused Lua UI checks cover search, no results, position restoration, resize
clamping, theme colors, and the realm setup entry point. Offline previews use
the actual Lua layout with substitute widgets. Native font metrics, scrolling,
focus, Escape handling, drag/resize, and skin presentation still need an in-game
check after `/reload`.
