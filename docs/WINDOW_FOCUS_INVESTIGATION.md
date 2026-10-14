# Window focus interference investigation

Date: 2026-10-14

## Finding

GGT's focus manager in `UI/Theme.lua` was managing windows owned by Blizzard.
This is a shared cause of the reported layering failures, not a separate defect
in each affected window. The earlier World Map and Trading Post exclusions left
the underlying external-window management enabled.

The previous implementation:

1. Registered fourteen common external window names, including `PlayerSpellsFrame`.
2. Also accepted any named frame listed in `UIPanelWindows`. This included
   `GarrisonMissionFrame` and could include other, later-loaded panels.
3. Walked upward from the mouse target and automatically registered matching
   ancestors. A global `OnUpdate` watcher ran regardless of whether GGT was visible.
4. Installed `OnShow`, `OnMouseDown`, `OnDragStart`, and `OnHide` hooks on these
   windows and wrote GGT focus metadata onto them.
5. Promoted them to at least `DIALOG`, changed their frame levels and top-level
   flag, and called `Raise()`. Restoration happened on hide, not when the user
   clicked a different external window.

The frame-level counter's nominal limit did not bound the resulting frame level:
the assignment also took the maximum of that counter and the frame's existing
level plus ten. Repeated external focus could therefore keep increasing levels.

## How the reported cases fit

- **Hero Talents:** `PlayerSpellsFrame` was explicitly registered. Blizzard's
  Hero Talents selector is a separate `UIParent` child at `DIALOG` strata, rather
  than a child of the main Talents window. Promoting Talents to `DIALOG` and
  increasing its level competes with that selector's native layering.
- **Garrison mission table and Baganator:** the mission table qualified through
  `UIPanelWindows`. GGT promoted it to `DIALOG`; it did not provide equivalent
  focus behavior for arbitrary bag-addon windows. Raising a bag window within a
  lower stratum cannot overtake the promoted mission table. Local Baganator
  sources confirm its backpack template is top-level and uses native frame
  behavior; GGT should not adjust either window to compensate.
- **Trading Post:** Blizzard parents static popups to the Trading Post while it
  is open and reparents them on exit. The earlier window-specific exclusion was
  confirmed working by the user, but did not protect other windows.

These findings are based on current GGT code, installed Baganator source,
Blizzard UI source, and regression tests. They do not constitute an in-game
verification of the new patch.

## Change

- Removed the external name lists, `UIPanelWindows` discovery, and all focus
  registration/restoration hooks for external windows.
- Restricted focus resolution and raising to GGT's explicitly registered
  windows. Explorer ownership redirects require both frames to be registered.
- Made direct focus requests for unregistered windows no-ops, and rejected
  registration with the former external role.
- Added a forbidden-frame guard before inspecting the mouse target's ancestry.
- Replaced the focus manager's per-frame polling with `GLOBAL_MOUSE_DOWN`.
  Clicking outside GGT can lower only GGT's own windows; it never raises,
  relayers, or hooks the external target.
- Kept GGT's own window focus and Explorer embedding behavior.

The remaining direct `SetFrameStrata`, `SetFrameLevel`, `SetToplevel`, and `Raise`
call sites were reviewed. They target GGT frames, embedded GGT panels, or GGT map
pins/controls. The shared theme library's `BringToFront` callers target GGT's
inventory detail and history popups. Trading Post visibility hooks and Auction
House sell-tab hooks remain; these control GGT's own UI and do not relayer the
external roots. No Baganator files or shared theme library files were changed.

## Verification

The first six new isolation tests were run before the production edit: five
failed and one errored, demonstrating external window mutations, both reported
layer promotions, unregistered focus acceptance, and forbidden-frame traversal.
All seven isolation tests pass after the fix, including an additional check of
yielding and returning focus between GGT and external UI.

The focused command covers focus, external isolation, bootstrap/Trading Post,
route-plan reopening, and Explorer embedding:

```powershell
busted tests/ui/theme_focus_spec.lua tests/ui/external_window_isolation_spec.lua tests/core/bootstrap_spec.lua tests/ui/farm_route_plan_window_spec.lua tests/ui/explorer_window_spec.lua
```

The broader `busted tests/ui tests/core/bootstrap_spec.lua` comparison is:

| Run | Passed | Failed | Errors |
| --- | ---: | ---: | ---: |
| Before edits | 208 | 6 | 29 |
| After edits | 215 | 6 | 29 |

The same failures/errors remain in material/map expectations and existing mocks
missing `FarmTrail`, `SetVerticalScroll`, `SetHitRectInsets`, `Theme`, or
`FauxScrollFrame_Update`. No additional failures/errors were introduced.
Lua syntax checks and focused test lint pass.

The tests use frame doubles and representative layer arrangements. They verify
that GGT does not mutate foreign frames; they do not simulate WoW rendering or
prove live button hit testing.

## Live verification still needed

Run `/reload` before testing. The previous Lua hooks and frame changes belong to
the current UI session; saving the files does not remove them.

1. Open Talents, then Hero Talents. Confirm the selector is visible and clickable.
2. Open the Draenor mission table, then Baganator. Alternate clicks between the
   windows and confirm the normal bag behavior.
3. Recheck Trading Post Purchase and Cancel.
4. Open GGT Explorer and Plan Route, switch focus, and reopen the route planner.
5. Repeat the external-window cases with GGT's main window hidden and visible.

## Source references

- [Blizzard Hero Talents dialog logic](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_PlayerSpells/ClassTalents/Blizzard_HeroTalentsSelectionDialog.lua)
- [Blizzard Hero Talents dialog layout](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_PlayerSpells/ClassTalents/Blizzard_HeroTalentsSelectionDialog.xml)
- [Blizzard panel registration](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIParentPanelManager/Mainline/UIPanelWindows.lua)
- [Blizzard Trading Post logic](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_PerksProgram/Blizzard_PerksProgram.lua)
- Installed Baganator: `../Baganator/ItemViewCommon/BackpackView.xml` and
  `../Baganator/ItemViewCommon/BackpackView.lua`.
