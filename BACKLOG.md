# General Gold Tracker Backlog

## Scope
- Improvement 6 is intentionally excluded from this round.
- Focus is on behavior fixes, shared runtime helpers, inventory performance, validation, and modularization groundwork.

## Completed In This Pass
- Auto-start on first tracked loot no longer depends on the tracker window being visible.
- History split now preserves stored highlight metadata instead of recalculating against the current threshold when data exists.
- The live loot log now shows filtered and vendor-only drops instead of silently hiding them.
- Shared item-binding logic was extracted into `Core/ItemBinding.lua` and reused by both loot valuation and inventory scanning.
- Inventory refreshes now reuse cached bag scans until bag state changes, and market-history writes were removed from every refresh.
- Added an opt-in setting to start a new session automatically when the zone or instance changes.
- Added a lightweight manifest/runtime validation script and CI step before packaging.

## Next
- Extract inventory scanning and caching into a dedicated non-UI service module.
- Extract session transition policy into a dedicated session flow helper.
- Extend help text and diagnostics to explain why an item was logged as `Soulbound`, `Below min quality`, or `Vendor only`.
- Add cache invalidation for any future non-bag market-data refresh triggers if the addon starts consuming them.

## Later
- Add lightweight automated tests around loot parsing, history merge/split, and location rollover decisions.
- Revisit history action safety and undo support in a separate pass.
