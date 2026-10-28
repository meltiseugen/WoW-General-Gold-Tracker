# Session history

History opens with search, date, character, and main-location filters. Pinned
recordings stay first. The configured rows per page is a maximum: smaller windows
show fewer complete rows. Back preserves the filters, page, selection, sorting,
and list position. Row actions contain rename, export, diagnosis, split, and delete.

Details opens on **Loot**. **Locations** groups subzones and floors under their
main location, shows separate recorded visits, and opens the corresponding loot
when clicked. Expand a location to inspect its path and visit times. Loot rows
can expand their source list; modified item clicks and farm actions remain available.
**Breakdown** explains the valuation and quantity categories.

Location and style filters scope totals, the breakdown, and exports. The loot-view
filter narrows the item table and exported items, without hiding money or changing
the scope's summary. Estimated value remains looted cash plus auction-valued items.
Vendor value is an alternative valuation, not an additional amount. Crafting
reagents overlap the other quantity categories.

## Session boundaries

In Options > Sessions & Loot, **Session boundaries** selects:

- **Continuous** (default): travel updates the visit, keeping the same session.
- **Each instance**: confirmed entry, exit, or switching instances splits the session.
- **Each major location**: also splits at a different outdoor zone.

Instance identity uses the instance map identifier; outdoor identity uses the
enclosing zone's UI map identifier. Floor and subzone names do not define a new
session. A reset that leaves the player inside the same instance identity does
not itself start a new run; use New Session for that boundary.

Existing explicit outdoor-splitting preferences migrate to Each major location.
Previously implicit instance splitting becomes opt-in. Automatic starting on login
or first loot stays independently configurable. New Session saves an active run
before clearing its live totals. Empty loot sessions retain the existing save rule.

Visits are updated on world-entry, zone-change, and loot events. There is no new
location timer, polling loop, or continuous coordinate sampling.

## Timing and resume

New sessions retain separate recording periods. Their union is recorded duration,
so reload downtime and gaps between resumed runs are excluded. Location duration
is the union of that location's recorded visits. Merging preserves periods and
visits instead of treating the gap between runs as elapsed farming time. Splitting
uses the same location grouping and recorded visits.

Resume saves another active session before continuing the selected row. When the
continued recording is stopped, its original history ID is updated. Loading the
same already-active row again is ignored, preventing repeated additions of its loot.

History honors the active-loot-time rate setting. This remains an estimate with
gaps capped at 90 seconds, and is labeled accordingly. A zero usable denominator
shows no rate instead of an invented value.

Old history is not deleted or silently converted into precise visit data. When
visits were never recorded, the UI shows Unknown time and exposes the first/last
loot span in expanded details. Older overall durations are labeled **Elapsed span
(legacy)**. A resumed recording containing an old period identifies the legacy span.

## Storage compatibility

Newly saved, resumed, merged, or split loot recordings use `storageVersion = 2`.
Their `locations` table stores repeated location descriptions once; loot and money
events retain a `locationRef`, their timestamps, quantities, values, sources, and
individual coordinates. Existing legacy records remain readable in their original
shape. Existing price snapshots are retained.

`GetSessionHistory()` hydrates compact event fields through a shared `__index`
context before existing consumers read them. Direct reads such as `event.mapID`
and `event.mapPath` continue to work. `pairs(event)` enumerates only stored fields;
code copying an entire compact record must preserve its locations table, or use
the normal history clone paths that read the public fields. Metatables are rebuilt
after SavedVariables loads and are not themselves serialized.

`recordingPeriods` and `locationVisits` are persisted separately from loot events.
`GetSessionIntervalDuration` sums the union of intervals, avoiding double counting
overlapping merged periods. The saved `duration` follows recorded periods for new
records, while `startTime`/`stopTime` retain the full calendar bounds.

## In-game verification

Offline Lua checks and rendered previews do not establish native WoW behavior.
After reloading, inspect all tabs at minimum and maximized sizes, small/large text,
and all six skins. Check item tooltips, modified clicks, menus, filters, export,
and Back. Exercise outdoor travel, instance entry/exit/floors in both Continuous
and Each instance modes. Confirm one history row survives a reload/resume with
separate periods, and that merge/split preserve totals and visits.
