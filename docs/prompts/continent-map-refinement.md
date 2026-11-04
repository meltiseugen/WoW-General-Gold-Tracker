Target continent(s): [REPLACE WITH THE CONTINENT OR WORLD TO WORK ON]
Additional focus areas / reference screenshots: [ADD THEM HERE, OR SAY “AUDIT THE ENTIRE CONTINENT”]

Work on General-Gold-Tracker's existing interactive maps. Bring the specified continent(s) up to the accepted rendering quality and visual rules established during the Northrend work. Inspect the entire target and its relevant zones, coastlines, cities, islands, shared landmarks, phases and map levels. Finish the implementation and appropriate verification; do not stop after improving one representative zone.

This prompt preserves decisions from a long, screenshot-driven conversation. My latest instructions and supplied screenshots take precedence. Unless I explicitly say “discussion only,” “plan first,” or “no code changes,” proceed with implementation after inspection and a concise explanation of what you found. Ask only questions that materially block the work. Do not repeatedly ask permission for already authorized, reversible work.

1. **Understand what already exists and preserve its behavior.**

   The original Alts feature had separate current-map and parent-map views. We replaced them with one reusable interactive map. Keep drag panning, smooth cursor-directed zoom, recorded character markers, and the Reset view button. A selected alt's map initially fits its recorded zone and can zoom out to its continent. I explicitly chose to explore and zoom into other zones anywhere on that continent, rather than locking detailed rendering to that alt's zone.

   The continent-group Map button uses the same renderer, initially fitting that continent. Its reset returns to the continent overview. The Global Map button at the top of Alts opens a separate movable, resizable window with four large tabs: Azeroth, Outland, Draenor and Shadowlands. Switching a tab or pressing reset fits its selected world; closing and reopening retains the current world's viewport. Preserve the distinction between a selected-alt map, a continent overview and a Global Map world view; do not accidentally impose the selected-alt navigation limit on a world tab.

   Keep the existing character/profession labels and marker projection across these hosts. Include the characters the host currently includes, including offline characters and existing role/level groups. Do not invent approximate positions when a saved location is unavailable. Preserve window resizing, clipping, viewport lifetime and existing reset/reopen behavior. Improve the shared component so the work benefits all its callers.

   **Both painted maps and minimap terrain must always be fully discovered/revealed, regardless of what the selected alt has explored.** This was an explicit correction to an earlier exploration-aware proposal. Preserve `revealAll = true` for Alts. Saved art/phase information still matters for choosing the correct version of a map; it must not restrict visibility. Do not require logging into every alt or capturing its exploration before a map can render.

   The advertised OpenMap features were research context. They are not a request to add unrelated flight-path planners, search, vendors, Questie integration, transport routes or other new features during this rendering task.

2. **Inspect the current project and establish the accepted baseline before editing.**

   Start with the working tree, any applicable repository instructions, `docs/interactive-maps.md`, `tools/README.md`, the target's runtime/data path and the relevant research receipts. Preserve unrelated dirty-worktree changes. Save a focused snapshot and hashes of the assets and code that could change. Capture matching before views before regenerating anything.

   Trace the target's actual root map ID, child map IDs, art IDs, native image dimensions, map hierarchy, physical world IDs, art variants, coordinate assignments and available terrain tiles. The recorded research baseline used client build `12.1.5.70529`; verify the intended client build and cached inputs before extending it. A UI map ID and an art ID are different identifiers. For example, Northrend's root map is 113 and its continent art is 118; Grizzly Hills uses art 121, while Zul'Drak is UI map 121 and uses art 126. Never transfer coordinates, masks, reference-canvas sizes or source samples between unrelated paintings by assumption.

   Read historical receipts as evidence of a particular iteration, not as instructions to restore every old implementation. Several older approaches were rejected or superseded. In particular, the older “whole Drak'Tharon from Zul'Drak” result and its lower caption ground patch are obsolete. The latest two-zone composition described below is the accepted version. Likewise, old shoreline-cleanup paths that removed the wanted depth contour were subsequently removed.

3. **Research OpenMap when useful, but author our implementation independently.**

   OpenMap and WOWIgnoredOpenMapClassic were installed locally for investigation. The Classic addon was manually placed in the retail AddOns directory. You may inspect their source to understand behavior, rendering passes and techniques, and compare their output against ours. Verify the installed versions rather than assuming the recorded beta version is still current.

   Do not copy their code, masks, polygon coordinates, data tables, textures, generated assets, libraries or globals into GGT. GGT must remain independent and work without either addon enabled. Use Blizzard's own client art and metadata as the primary inputs and record provenance. Consult current API/client UI sources and primary technical resources when needed. Evaluate reference techniques critically; the objective is cleaner components and better rendering, not reproducing their bugs.

4. **Preserve the original ocean artwork and distinguish decorative frames from cartography.**

   This is one of my strongest preferences. I rejected broad replacements of the ocean surrounding Northrend: generic mottled noise, synthesized background styles, stretched or repeated water samples, row-interpolated fills, and large artificial horizontal stripe patterns. Do not recreate those experiments on another continent.

   Use the target continent's own original overview ocean as the visual reference and preserve that artwork around the continent through the painted zoom levels. Detailed zone art should replace the appropriate land detail without turning the surrounding sea into a different style. Do not run a generic ocean/backdrop generator as a routine follow-up to every fix. Existing fallback behavior on other maps is not proof that a full-ocean replacement is the desired result for the target.

   Some map edges are baked into Blizzard's image pixels: metal ornaments, portraits, burnt parchment, decorative ships, oversized old captions and rectangular template fringes. Hiding a UI frame does not remove them. Use artwork-specific, independently authored masks and narrowly reviewed repairs. Preserve real land, islands, shoreline ink, place names and intended landmarks while removing unwanted frame material. Verify an object's identity against the source before deciding it is decorative debris.

   Do not blanket-cut a large diagonal corner merely because it usually contains an ornament. That approach hid intact shallow water and the wanted contour in Northrend's bottom-right corner. Inspect the original RGB first. Keep original cartography wherever it is intact; replace only the ornament or damaged frame edge.

   When removing a frame leaves a corner hole, fill the hole with matching ocean context from that same continent. Preserve the original palette, grain, hatch scale and nearby contour. The fill must remain anchored to map coordinates during pan/zoom. Use sparse, mipmapped assets at appropriate native resolution. Keep the repair confined to its reviewed support; do not repaint the surrounding continent to hide one corner defect.

5. **Preserve the two water contours and apply the requested fine texture only in the correct band.**

   My terminology is:

   - **X** is the original outer painted contour separating shallow/coastal water from the deeper ocean, visually associated with the fatigue boundary.
   - **Y** is the inner/intermediate shoreline contour delimiting the coastal-water band toward the land.
   - **Between Y and X**, I prefer the fine, short horizontal hatch marks visible in the detailed native zone artwork, rather than the coarse mottled/noisy texture that showed through from the parent painting.

   Identify these contours in the target's original and detailed artwork before editing. Preserve the actual native X ink. This is restoration of a painted cartographic feature, not a request to fabricate exact gameplay fatigue coordinates or draw an approximate new line around the continent.

   Missing sections of X were previously caused by cleanup stencils erasing it and by broad corner masks hiding it. Fix the cause and expose the original contour where available. Do not “clean up” a coastline by deleting the contour I wanted to keep.

   My dislike of artificial horizontal stripes does **not** mean that all horizontal marks are forbidden. The later request explicitly prefers **fine native hatching within Y–X**. Preserve the original ocean artwork beyond X, including its own native marks; do not extend generated coarse bars across it. Keep the overview's existing design. Introduce the fine coastal hatching with the zone-detail transition, as the accepted Northrend implementation does.

   Use a clean, reviewed native fine-hatch sample at the correct geographic pixel scale. Preserve local water colours, avoid recognizable repeated source rectangles and keep the pattern stable while navigating. Perform synthesis, image analysis and masking offline, not during gameplay.

   Protect actual detailed coastlines, islands, beaches, headlands, buildings and labels. The inner limit cannot be inferred solely from the coarse parent continent's land outline: fine zone coasts differ. Revealed/base-image differences help, but already-visible land may not change with exploration and needs an explicit reviewed outline. Onslaught Harbor, Wintergrasp and Hrothgar's Landing illustrate this limitation. Retain both Y and X rather than painting over them to make the fill look continuous.

6. **Make world/continent/zone/minimap transitions geographically correct.**

   The early Outland/Hellfire failures showed continent-style lettering mixed with scattered rectangular pieces of zone art, followed by tiny isolated minimap rectangles. Those are failures to investigate, not acceptable transition effects. Check projection, tile placement, scaling, UVs, art variants, mask geometry and draw order. Do not hide a coordinate error by arbitrarily delaying terrain, lowering its opacity or increasing zoom limits.

   Ordinary sibling zones should enter through a coordinated, short continent-context transition. Avoid independent zone clocks that leave a patchwork of different map levels. Apply a zone's territory consistently to its base and revealed pieces. Paint neighboring regions in a deliberate order so one zone's parchment, frame or halo cannot erase another zone's detail.

   Close minimap terrain should align, join continuously across compatible zones and become fully opaque. Large painted place names should not remain visible through it. The current shared terrain policy blends at approximately 100–130 screen pixels per native terrain tile; inspect the current code before changing it. Geographic projection and tile density matter more than one hard-coded zoom value for every continent.

   Native terrain uses the game's north/west world axes and east/south tile indexing; verify transformations and texture orientation. Use active, build-matched terrain records rather than stale listfile candidates or invented FileDataIDs. Draw compatible terrain once per physical projection, not repeatedly through overlapping zone rectangles. Separate physical worlds, diagram layouts, map floors and incompatible projections require their own handling. Retain underground city/interior paintings where outdoor minimap textures cannot describe their rooms.

   Do not classify an outdoor zone as a city merely because its relative area is small. An earlier area threshold broke Redridge, Swamp of Sorrows and other small outdoor zones. Use hierarchy and map semantics. Preserve phase-specific art and coordinates; never apply another phase's mask blindly.

7. **Treat labels, shared landmarks and small features as first-class rendering requirements.**

   Place names must remain complete across ownership seams, tile boundaries and transitions. Protect the whole intended name, with feathering outside the letters. Suppress duplicate names deliberately. Do not fix half a word by exposing a rectangular patch of unrelated parchment or painting ground over an adjacent structure.

   Automatic lettering detection previously selected fortress masonry and a metallic frame ornament, which reappeared as a white airplane-like artifact. Prefer explicit, reviewed label regions. Check that label masks do not redraw buildings, frame pieces, coastline strokes or unrelated symbols above the scene.

   Compare both native zone paintings at every shared landmark. One painting does not always supply the best entire result. The latest accepted Drak'Tharon composition is definitive: **Zul'Drak supplies the upper walls, stone border and surrounding ground; Grizzly Hills supplies the complete castle body and tall front gate; one complete name sits above it.** The duplicate lower Zul'Drak lettering is suppressed. The old ground patch over that lower caption was removed because it covered the desired gate.

   `landmark_composites` now supplies an explicit foreground outline and a soft cut in the other painting. The foreground must remain opaque through the entire soft cut. Two partially transparent ownership masks can expose unwanted coarse continent art between them. Keep structures whole and blend through appropriate ground or border art instead of slicing horizontally through masonry. Do not revert to the superseded whole-Zul'Drak castle.

   Match neighboring mountains, cliffs, forests and ground naturally. The Avalanche at the Sholazar/Icecrown edge was a specific example where OpenMap initially blended the native ridge better. Preserve the useful native mountain band; avoid abrupt horizontal strips, rectangular joins and inappropriate colour bleed.

   Preserve disconnected and tiny islands at every level. Hrothgar's Landing was visible in the overview but disappeared on zoom. Wintergrasp was missing because its declared exploration records contained no visible pixels. Empty exploration alpha must not suppress usable, already-revealed base art. Check small islands and base-only maps explicitly rather than relying on the main zone examples.

8. **Learn from the small Northrend defects without replaying their rejected fixes.**

   The 15-image investigation covered: a misplaced Icecrown/Wintergrasp spike; the oversized Nexus fragment north of Coldarra; Riplash's old coast and clipped decorative water art; a Kamagua frame portrait/coast fragment; the clipped ship near Explorers' League Outpost; the Vengeance Landing plane-like ornament; the horizontal Howling Fjord mountain seam; old Venture Bay coast/islands; debris around the Hrothgar channel; Onslaught Harbor's shore and caption; southern Dragonblight's old shoreline; cropped Silverbrook text; the Drak'Tharon structure seam; cropped Apothecary Camp text; and the Thor Modan/Bloodmoon coastal join.

   These are examples of defects to audit on other continents, not coordinates or cleanup stencils to copy. Some early repairs erased useful coastline or depth-contour ink, and were rolled back. Treat later contour, corner, hatching and Drak'Tharon decisions as overriding obsolete instructions in the original 15-defect receipt.

   When I supply screenshots, inspect them individually, keep a numbered issue list and verify each fix against the corresponding image. Do not turn a request for several delicate local repairs into a redesign of the ocean or the whole map. If an earlier version looked better, identify which art, mask, ownership decision or repair caused the regression and recover that visual choice without reverting unrelated successful work.

9. **Use the existing component boundaries and data-driven tooling.**

   Inspect these components and preserve their responsibilities:

   - `UI/Maps/Geometry.lua`: coordinates, clipping, constraints, pan/zoom and cursor anchors.
   - `UI/Maps/MapSource.lua`: native API adapter, hierarchy, art/phase selection, overlays and terrain data.
   - `UI/Maps/MapScene.lua`: hierarchy-wide scene planning and shared transition contexts.
   - `UI/Maps/MapRenderer.lua`: rendering passes, visible tiles, pooled textures/masks, terrain and local generated patches.
   - `UI/Maps/InteractiveMap.lua`: reusable viewport, interactions, reset, markers and lifecycle.
   - `ArtMaskIndex.lua`, `OceanIndex.lua`, `CornerFillIndex.lua` and `WaterHatchingIndex.lua` under `UI/Maps/`: lightweight asset availability/placement indexes.
   - `Core/AltTracker.lua`, `Core/AltMapOverview.lua`, `UI/AltsWindow.lua` and `UI/AltsGlobalMapWindow.lua`: existing capture, saved-position projection and map hosts.
   - `Data/General-Gold-Tracker_MapData/`: optional load-on-demand, build-pinned terrain/overlay metadata.

   The reusable map exposes `SetSubject`, `Reset`, `Resize` and `ProjectPoint`; preserve that separation from Alts-specific data and labels. Prefer reviewed per-art data and reproducible offline asset changes when the problem is in one painting. Change shared rendering logic only when the defect actually belongs there, and then verify the other hosts and continents.

   Relevant tooling includes:

   - `tools/map_art_adjustments.json`: reviewed interiors, priorities, cutouts, labels, local repairs and landmark composites.
   - `tools/generate_map_art_masks.py`, `map_art_ownership.py`, `map_art_labels.py` and `map_mask_texture.py`: native-art ownership, masks, labels and mipmapped BLP output.
   - `tools/map_art_backgrounds.py` and `map_texture_repair.py`: narrowly scoped native-context repairs; not authorization to regenerate an entire ocean.
   - `tools/map_corner_fills.json` and `generate_map_corner_fills.py`: ornament-aware corner restoration, original-cartography protection and native-pixel probes.
   - `tools/map_water_hatching.json` and `generate_map_water_hatching.py`: reviewed Y–X water bands, fine native hatching and shoreline protection.
   - `tools/map_preview_data.py` and `preview_interactive_map.py`: build-pinned hierarchy/projection fixtures and offline previews/audits.
   - `tools/generate_map_terrain.py` and `fetch_map_metadata.py`: native terrain metadata generation/research.

   `generate_map_art_masks.py --roots ROOT_ID --arts ART_A ART_B` can export selected paintings while retaining sibling context and leaving continent/background assets alone. Composite partners must be rebuilt together. Use a whole-root rebuild only when needed. Do not regenerate all continents, oceans, corner fills or terrain catalogs for a local mask fix.

   Northrend is a reference implementation, not a universal coordinate template. Extend the recipes and indexes for the target's own art IDs and source dimensions. Keep different coordinate conventions explicit: normalized painting coordinates, native pixels, reference canvases, physical worlds and UI-map rectangles are not interchangeable.

10. **Keep resource usage bounded and rendering lazy.**

    Keep Explorer/Alts opening lightweight. Defer map creation, catalog loading and texture expansion until their existing explicit use points. Do not add permanent position tracking, timers, polling or continuous scans. Preserve existing event-based capture and explicit refreshes. Existing drag/zoom animation updates must detach when idle or hidden.

    Reuse texture pools, cull invisible regions and release texture/mask file references when culled or closed. Preserve bounded terrain caches. Do not repeatedly render a continent's terrain through every zone. Do image processing, stitching decisions and texture synthesis offline; ship the resulting compact metadata and assets.

    Use mipmapped compressed assets and sparse placement instead of huge transparent allocations or unnecessarily enlarged images. Keep native pixel scale where detail matters. The current renderer has limits of 256 candidate terrain tiles per projection and 4,096 active regions; verify the current constants. Detect and report budget exhaustion rather than silently dropping later zones. Earlier lower region limits omitted maps during modern continent transitions.

    Preserve the client's mask behavior: masks use their complete image geometry in map coordinates, including transparent padding. Clip and UV-crop painted/terrain textures appropriately. Do not rely on MaskTexture UV cropping working like ordinary Texture cropping. Verify both native placement and the preview's assumptions.

11. **Validate the rendered result, scope and integration.**

    Before/after views must use the same camera, focus, zoom and client build. Inspect overview, transition start/middle/end, full zone detail, early terrain blending and deep terrain where the task affects them. Inspect all sides of the continent, awkward seams, city edges, offshore islands and the supplied reference locations. One attractive crop or an audit with no images is insufficient visual evidence.

    Preview examples, after replacing the uppercase placeholders with verified IDs/coordinates:

    ```powershell
    uv run --offline --no-project --cache-dir .local/uv-cache --with pillow --with lupa python tools/preview_interactive_map.py --continent ROOT_ID --focus ZONE_ID --at X Y --zooms 1 1.4 1.5 1.6 2 3 --output .local/interactive-map-preview/TARGET-after
    ```

    Choose additional target-appropriate zooms for terrain; the example numbers are not universal transition thresholds. Use fresh output directories after changes. Do not reuse stale previews as proof. If cached terrain inputs are missing, either obtain the correct inputs or explicitly distinguish an art-only diagnostic from a real terrain preview.

    Run the applicable map Python checks and addon manifest validation:

    ```powershell
    uv run --offline --no-project --cache-dir .local/uv-cache --with pillow --with numpy --with scipy python -m unittest discover -s tests -p 'test_map_*.py'
    python3.13 tools/validate_addon.py
    ```

    Use the available Lua test runner for the relevant renderer, Alts, overview/projection and host tests, and parse affected Lua with Lua 5.1. Key suites include `tests/ui/interactive_map_spec.lua`, `tests/ui/alts_window_spec.lua`, `tests/core/alt_map_overview_spec.lua`, `tests/core/alt_tracker_spec.lua`, `tests/core/alt_destinations_spec.lua`, `tests/ui/explorer_window_spec.lua` and `tests/ui/theme_focus_spec.lua`. The Python `test_map_*.py` suites cover masks, corners, water hatching, terrain and preview metadata. A local Lupa-based harness has been used when native Busted was unavailable; report it accurately. Helpers under `.local/` may not exist in a fresh checkout. Verify dependencies and report skipped or blocked checks instead of treating them as passes.

    If shared rendering, hierarchy, projection, draw order or budgets change, audit `preview_interactive_map.py --all-continents --audit-only` and `--global-cases --audit-only`, with fresh output directories. Supplement those audits with actual raster previews. Check the selected-alt card, continent-group map and relevant Global Map tabs.

    Verify scope quantitatively where practical: compare unchanged asset hashes; inspect mask-difference bounds; check native contour/island/landmark probes; and compare rendered pixels outside the intended repair. If a cleanup output is no longer referenced, remove only generator-owned files whose hashes still match their receipt. Preserve manually changed or unrelated files.

    Record source/build information, reviewed coordinates, generated asset hashes, affected regions, commands/checks, before/after evidence and limitations in a new or appropriately updated `docs/research/` receipt. Raw client inputs, temporary scripts and previews belong under `.local/`; durable generation logic and annotations belong in the tools/data structure. Do not overwrite unrelated provenance or silently mix client builds. The last completed Drak'Tharon iteration recorded 51 Python map checks and 115 focused Lua-harness checks; those are historical results, not permission to claim a new change passed without rerunning its checks.

12. **Be honest about native verification and continue work carefully across interruptions.**

    Offline Lua/Pillow images, source hashes, parser checks and manifests do not prove native WoW GPU masking, texture caching, performance or interaction behavior. The previous work still required in-game verification. State what was actually tested and what remains pending. A full WoW restart can be necessary to refresh changed/new textures and loading entries. Native verification should cover pan/zoom/reset, resizing, transitions, markers, hidden/idle behavior and operation with the reference addons disabled; check coexistence when relevant.

    If work is interrupted by context or usage limits, preserve a concise record of completed changes, accepted/rejected visuals, generated outputs and pending checks. Resume from the current working tree and evidence when I say to continue. Do not restart from an obsolete baseline, rerun rejected ocean experiments or undo accepted work simply because the conversation was compacted.

    Finish with a concise explanation of the visible change, a useful before/after comparison, the actual validation results and any remaining limitation. Do not call a visual defect fixed solely because tests passed. Do not claim a screenshot is a native game result when it is an offline preview.

Read these records to recover implementation details and distinguish historical attempts from the latest accepted result:

- `docs/interactive-maps.md` and `tools/README.md`.
- `docs/research/map-transition-coverage-2026-10-24.json`, `map-small-zones-2026-10-24.json`, `map-terrain-2026-10-24.json` and `map-seams-2026-10-25.json`.
- `docs/research/map-northrend-2026-10-25.json` and `map-northrend-details-2026-10-25.json` for the original diagnostic cases, with the later corrections above taking precedence.
- `docs/research/map-contour-2026-10-25.json`, `map-corners-2026-10-25.json` and `map-southeast-2026-10-25.json` for native ocean/contour preservation and selective corner restoration.
- `docs/research/map-water-hatching-2026-10-25.json` for the requested Y–X fine-water treatment.
- `docs/research/map-draktharon-2026-10-25.json` for the latest accepted two-zone landmark composition.
- `docs/research/map-art-masks-2026-10-24.json` for the merged generated-art receipt. Its filename is historical; inspect its contents and hashes rather than inferring its generation state from the date alone.

If still available, useful accepted-result comparisons are `.local/interactive-map-preview/southeast-comparison.jpg`, `.local/interactive-map-preview/water-hatching-comparison.jpg` and `.local/interactive-map-preview/draktharon-comparison.jpg`. These are offline visual evidence, not native screenshots or generator inputs. Locate any other required evidence from the receipts and current workspace rather than assuming temporary files are portable.

Start by inspecting the target and giving me a short, concrete assessment of its rendering problems and the first bounded changes you will make. Then implement, inspect the results, correct regressions and finish the authorized work according to the rules above.
