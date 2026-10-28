# Diagnosis window

Enable **Runtime diagnostics** in **Options > Advanced**, reproduce the issue,
then open **Diagnosis** from the tracker. Press **Refresh** after reproducing new
activity. The window uses manual snapshots and has no automatic refresh loop.
Changing tabs, filtering zeros, resizing, and copying keep the displayed snapshot
stable. Reopening the window or selecting a scope reads fresh data.

## Scopes

| Scope | What the counters cover |
| --- | --- |
| Runtime | Captured activity since login, `/reload`, or **Reset runtime**. Can span several sessions. |
| Current session | The current session's own diagnosis snapshot. Capture can start after the session begins. |
| Saved diagnosis | The stored snapshot opened from History. Available even when runtime diagnostics are disabled. |

Capture start and viewing timestamps appear under **Snapshot details** and in the
report. Disabling capture leaves gaps in coverage; it does not turn uncaptured
activity into zeros. A split recording carries its source session's snapshot,
which is explicitly labeled as covering the source session rather than the
selected location.

**Reset runtime** clears only runtime counters and timing buckets. It preserves
the current session's diagnosis snapshot, saved snapshots, and recorded loot.
It is available only in the Runtime scope.

## Views and reports

- **Overview** shows capture context, item and money record counts, relevant
  things to check, and snapshot details.
- **Loot pipeline** groups parsing, recording/filtering, and coordinate/material
  location counters. Entries and item quantities are labeled separately.
- **Events** includes bag, auction house, zone, mail, and loot events. Hover a
  metric row to see its internal key.
- **Timings** separates average, maximum, last call, and sample count. Values are
  milliseconds; `n/a` means there were no samples. Nested timings overlap and
  cannot be added to obtain total addon CPU usage. This view does not measure
  addon memory or diagnose every possible performance problem.

**Hide zeros** filters counter rows in Loot pipeline and Events. **Copy report**
opens selectable text for the displayed scope; use Ctrl+A and Ctrl+C. The report
always includes zero counters and every metric, including unfamiliar metrics
retained in older snapshots. Escape or **Back to diagnosis** returns to the view.

Ignored messages and filtered items are not automatically failures. Coordinate
retry counts are cumulative attempts, not a count of currently pending retries.
Missing coordinates alone do not establish that loot was lost.

## Validation

Focused Lua checks cover scope isolation, manual refresh, runtime-only reset,
complete reports, zero filtering, missing/deleted snapshots, saved split scope,
scroll restoration, and layout geometry in all six skins from 640x480 to
1280x960. Offline previews render the actual Lua widget geometry.

Native WoW verification remains required after `/reload`: inspect each tab and
skin, resize/maximize/drag, scroll long lists, test report selection and Ctrl+C,
reproduce loot and refresh, then compare Current session and saved History
snapshots before and after Reset runtime.
