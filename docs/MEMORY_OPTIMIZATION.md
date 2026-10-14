# Memory changes — 2026-10-14

The reported WoW footprint was approximately 166–177 MB after `/reload`, without opening
Explorer. A manual full Lua collection reduced the in-game reading to 120.6296 MB. This
identified both a substantial retained baseline and temporary allocations; it did not
establish a continuously growing leak.

## Implemented changes

- **On-demand catalogs:** 141 unchanged dataset files now live in five companion addons.
  Main startup keeps FarmingItems, learned defaults and a compact material metadata index.
  Namespace access invokes `C_AddOns.LoadAddOn` for the relevant catalog. Farms retain
  their existing pet/toy/drop dependencies and material initialization order is unchanged.
  The main addon does not list the data addons as eager dependencies.
- **Material price scope:** candidates come from the same material set consumed by Alerts,
  instead of recursively walking drop catalogs, session history, favorites and bags.
  First access migrates known-price storage, retaining priced material records and their
  existing latest/previous samples. Empty/non-material automatic entries are discarded.
  Candidates without prices no longer create persistent records. Processed candidates
  and the completed candidate list are released promptly.
- **Detailed market history:** dense arrays plus one shared field-access metatable replace
  large per-sample hash tables. On load, old named records migrate and packed records regain
  named access. Existing field values, history limits and extension fields are preserved.
  Pruning compacts snapshot arrays in place. Existing-item loot writes enforce the per-item
  cap immediately without traversing all histories more than once per five minutes; adding
  an item still enforces the overall item cap immediately.
- **Startup work and UI:** archived rare/instance scan caches are no longer repriced merely
  because the player logs in. Actual loot, bag snapshots, scans and explicit price updates
  still record history. The tracker and full Options window are constructed on first open;
  the small Blizzard Settings entry is registered at login. Hidden tracker refreshes return
  before rebuilding display data.
- **Explorer caches:** hidden material views release item/demand/display caches; hidden
  instance views stop transmog pricing and release rebuildable transmog rows; inactive
  Drops views release item/price caches; Inventory releases its derived bag cache when no
  item-details window needs it. Completed/cancelled rare scans discard working tables.
  Active scans, unsaved results, selections, favorites and saved scans remain intact.

Session history already has a 300-session retention cap. It was a much smaller contributor
than catalog and price storage, so this change does not shorten that cap or discard loot
records. Reusable UI widgets and requested catalog tables remain resident after first use.
The optimization does not periodically force global garbage collection or unload addons.

## Standalone comparison

Lua 5.1.5, the same local saved-data snapshot, full collection at each measurement:

| Measurement | Previous code | New code |
|---|---:|---:|
| Runtime definitions and initial data | 41.590 MiB | 4.359 MiB |
| Normalized startup including saved data | 87.614 MiB | 21.360 MiB |
| During price-candidate construction, retained | 108.062 MiB | 22.155 MiB |
| Price candidates | 29,722 | 1,135 |
| Saved known-price entries after normalization | 29,798 | 1,097 |
| Detailed item histories | 500 | 500 |
| Detailed snapshots | 14,802 | 14,802 |

The startup retained estimate falls about 76%. These are **not live WoW memory readings**:
native frames, live inventory/TSM calls, the game's allocator and its addon attribution are
not reproduced. Loaded data modules must be included when comparing total GGT memory.

Reproduce without modifying SavedVariables:

```text
lua5.1 tools/profile_memory.lua "path/to/SavedVariables/General-Gold-Tracker.lua" --baseline
lua5.1 tools/profile_memory.lua "path/to/SavedVariables/General-Gold-Tracker.lua"
```

The baseline reads tracked code from Git HEAD and locates the unchanged relocated datasets.
Each process reads the saved file independently and never writes it back.

## Verification

- Compared all 141 relocated dataset files with Git: their contents are unchanged.
- Checked all 14,802 detailed saved snapshots before/after migration: every field retained;
  other saved-data roots keep the same references after the memory migration.
- Tested main-TOC loading, no catalog loads during initialization/material scanning/Alerts,
  per-module first access, cross-catalog augmentation, missing-module errors, material-index
  parity, known-price migration, unpriced candidates, packed-snapshot round trips, pruning,
  hidden-cache lifecycle, active-scan preservation, and lazy tracker/settings creation.
- Lua 5.1 parses all runtime files. All six manifests validate, including module paths,
  load-on-demand metadata, dependencies and matching interface versions.
- Broader tests contain existing unrelated data assertions and UI mock failures. The known
  data suite still has 10 failures; the previously sampled UI suite still has its one
  rare-map ordering failure and five mock errors. Do not describe the broad suite as green.

## In-game verification still required

1. Fully restart WoW once so it discovers the five companion addon folders. Enable GGT and
   its bundled data addons. Subsequent code edits only require the usual `/reload`.
2. With Explorer unopened, wait for startup work to settle and compare memory after a full
   collection. Sum the main addon and every `General-Gold-Tracker_*` module.
3. Open the tracker in each saved opening mode, Options, Inventory, Alerts, then each Explorer
   catalog; verify materials/maps, rare scans, instance pets/transmogs, drops and farm routes.
4. Close/reopen views while scans run and after completion; verify unsaved results remain
   usable and repeated cycles settle rather than growing without bound.
5. Reload after saving: check price graphs/Alerts, session history, favorites, farms and user
   pins to validate the actual WoW SavedVariables serialization round trip.

Loader API: [Blizzard's AddOns API declarations](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua).
Packaging: [CurseForge's module folder layout documentation](https://support.curseforge.com/support/solutions/articles/9000197952-preparing-the-packagemeta-file).
