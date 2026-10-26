# Developer tools

Run these from the repository root. This folder is excluded from release packages
by `.pkgmeta`; WoW does not load these scripts. Generated catalogs, source policies,
and research receipts still need their generators for future updates.

## Validation and local setup

| Tool | Purpose / requirements |
| --- | --- |
| `validate_addon.py` | Validate manifests, runtime file coverage, and load order. Python standard library; also runs in CI. |
| `run_tests.ps1` | Run the Lua specs and test linting. Requires `busted` and `luacheck` on PATH. |
| `install_catalog_modules.ps1` | Create sibling catalog junctions for this checkout. Restart WoW after first installation. |
| `profile_memory.lua` | Approximate startup/scan memory in standalone Lua using optional SavedVariables. See `docs/MEMORY_OPTIMIZATION.md`; results are not live WoW measurements. |

```powershell
python tools/validate_addon.py
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
```

## Catalog generation

These commands write generated data. Review the resulting diff after refreshing
an upstream addon or changing source records.

| Tool / data | Purpose / requirements |
| --- | --- |
| `generate_material_index.lua` | Rebuild `Data/MaterialIndex.lua` after Materials changes. Lua 5.1 or newer. |
| `generate_farm_catalog_snapshot.py` | Rebuild Gathering, Drops, and Farms snapshots from `--source-root`. Python standard library. |
| `generate_atlasloot_snapshot.ps1` | Rebuild instance loot from installed sibling AtlasLoot modules. PowerShell. |
| `generate_att_boe_snapshot.lua` | Rebuild instance/zone/world BoE loot from sibling AllTheThings and the instance snapshot. Lua; Windows paths. |
| `generate_rarescanner_snapshot.py` / `.ps1` | Alternative Python and PowerShell generators for the same RareScanner snapshot. Run one, using the installed sibling RareScanner. |
| `catalog_exclusions.py` / `.json` | Shared product exclusion policy used by snapshot/research tools. Keep both files. |
| `export_crafting_farming_learned.lua` | Export learned data from a SavedVariables file into `Data/CraftingFarmingLearned.lua` or a supplied output path. Lua. |
| `research_cosmetic_catalog.py` | Discover cosmetics from sibling TODO-Planner and preserved source records; optionally fetch tooltip evidence. Requires `lupa.lua51`. |
| `cosmetic_primary_sources.json` | Preserve original sources for cosmetics migrated out of Materials. Input to cosmetic research. |
| `generate_cosmetic_catalog.py` | Build Cosmetics from the audited JSON files under `docs/research`; no network or sibling addon needed. |

## Map research and preview

| Tool | Purpose / requirements |
| --- | --- |
| `research_material_maps.py` | Refresh cached item/spell receipts for Pandaria, Draenor, or Legion. Python standard library; `--refresh` downloads sources again. Replaces three expansion-specific copies. |
| `audit_draenor_material_maps.py` | Verify Draenor map enrichment and export coverage. Requires `lupa.lua51`. |
| `audit_legion_material_maps.py` | Verify Legion map enrichment and export coverage, optionally an item-by-item report. Requires `lupa.lua51`. |
| `audit_bfa_material_maps.py` | Exercise Materials UI/map builders for BfA, Shadowlands, Dragonflight, War Within, or Midnight using `--expansion`. Requires `lupa.lua51`. |
| `generate_map_terrain.py` | Generate terrain facts from client CSV/listfile/WDT metadata. Python standard library. |
| `fetch_map_metadata.py` | Fetch version-pinned WDT manifests used by the terrain generator. Python standard library; network required. |
| `generate_map_edge_mask.py` | Rebuild the original edge feather and rounded locality masks in `UI/Maps/Media/`. Python standard library. |
| `generate_map_art_masks.py` / `map_art_ownership.py` / `map_art_labels.py` / `map_mask_texture.py` | Compare native revealed/base paintings, assign overlapping regions to neighbouring zones, and generate independent mipmapped BLP masks with provenance. `map_art_adjustments.json` holds reviewed outlines, whole labels, landmark composites, ornament cutouts and background samples. `--roots 113` rebuilds Northrend into an existing same-build receipt; add `--arts 121 126` to export only those paintings and their caption/label changes while preserving continent/background assets. Composite partners must be rebuilt together. Requires Pillow, NumPy and SciPy; `--download` explicitly fetches missing client inputs. |
| `map_art_backgrounds.py` | Generate local, feathered native-art repairs for marked coastline/landmark fragments and duplicate captions. The original continent ocean remains intact. Uses the same offline dependencies as the mask generator. |
| `map_texture_repair.py` | Independently authored native texture quilting with context matching, minimum-error cuts and gradient integration. Used offline only inside reviewed defect stencils and the small duplicate-caption repair; technique reference: [Efros and Freeman, SIGGRAPH 2001](https://people.eecs.berkeley.edu/~efros/research/quilting.html). No reference-addon code or assets are inputs. |
| `generate_map_corner_fills.py` | Restore the two masked continent-frame corners using `map_corner_fills.json`. Reviewed ornament outlines retain intact native shallow water and depth contours; only missing ocean uses the native water samples. Run after mask generation with the same cached client build. Generates sparse mipmapped assets, `CornerFillIndex.lua` and a source/hash receipt with native-pixel checks. Requires Pillow, NumPy and SciPy; uses cached textures. |
| `generate_map_water_hatching.py` | Extend fine native water hatch ink through the reviewed Y-to-X coastal band. `map_water_hatching.json` supplies contour annotations and the native sample; revealed zone interiors and existing core annotations protect land and offshore islands. Generates sparse mipmapped patches, `WaterHatchingIndex.lua` and a source/hash receipt from cached client textures. Requires Pillow, NumPy and SciPy. |
| `generate_map_ocean.py` | Run after the mask generator to create detail backdrops from native ocean colour/frequency statistics with independent random phase; prevents repeated symbols and coarse continent labels leaking through zone edges. Uses the same offline dependencies. |
| `preview_interactive_map.py` | Render Lua map zoom stages offline using client metadata and cached textures. `--outland` checks Hellfire; `--kalimdor` checks thirteen Barrens stages; `--azeroth` checks eighteen world-to-Kalimdor stages. `--renderer` / `--scene` accept saved baselines; `--zooms 3 5` selects exact zoom factors. Requires `lupa.lua51` and Pillow; `--download` fetches missing textures. |
| `map_preview_data.py` | Shared build-pinned client fixture reader for geographic, nested, diagram and inset maps. Used by `preview_interactive_map.py --all-continents` / `--global-cases`; requires `UiMapLink.csv` alongside the existing map metadata. `--audit-only` skips texture downloads and images. |

The audit scripts check different expansion data and UI contracts; they are not
duplicates. Preserve research receipts in `docs/research`. Raw downloads and
previews belong in `.local`; Python bytecode caches are disposable and ignored.

For example, reuse a previous source index as the next inventory:

```powershell
python tools/research_material_maps.py --expansion legion --inventory docs/research/legion-base-map-source-index-2026-10-21.json --cache .local/legion-map-sources --output .local/legion-map-source-index.json
```

See `docs/interactive-maps.md` for terrain generation and preview inputs. Headless
audits and previews do not establish live WoW rendering or gameplay behavior.
