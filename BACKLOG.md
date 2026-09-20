# General Gold Tracker Backlog

### Issues:

X - general window:

X - our map window:

X - "Item market details" window:

X - rares window:

X - instances window:

X - drops window: 

X - bags window:

X - materials window:

X - alerts window:


### Next:



The following do not currently appear as their own named, coordinate-backed farming entries and deserve investigation:
- Primal Bat Leather
- Primal Tiger Leather
- Turtle Scale
- Heavy Scorpid Scale
- Warbear Leather
- Crystal Infused Leather
- Dark Rune
- Golden Pearl
- Breath of Wind
- Tallstrider Sinew
- Empty Magma Shell
- Sargha’s Signet
- Dreamscales
- Stuffed Deviate Scale Pouch
- Mote of Night

Special handling:
- Mooncloth belongs in the conversion system, not as an ordinary outdoor route.
- Ancient Mana Crystal should likely be excluded from the gold-opportunity catalog if it remains non-tradeable.
- Exact item IDs, present-day availability, binding, and routes must be independently verified from public sources before inclusion.
- Route coordinates should not be copied from the paid guide’s drawings.



Phase 1 — Introduce a first-class FarmProfile
The current model is item-centric. The guide repeatedly describes farms that have several outputs, prerequisites, routes, and conditions. Add a new conceptual entity:
FarmProfile
  id, title, expansion, category
  mode: solo / group / raid
  locations and route IDs
  primary and secondary item outputs
  requirements:
    professions, class, specialization, consumables
    quest/phase, level, group size
  schedule:
    always, daily, weekly, world-quest, event, instance-reset
  warnings and preparation notes
  public source URLs
  researchedAt, lastVerifiedAt, confidence, status
Keep the existing per-item records. A compatibility layer should derive the current item map options from farm profiles, so this does not require a disruptive rewrite.
Why this matters:
- One Primal farm can yield a primary mote, BoEs, patterns, and raw gold.
- One skinning route can supply leather, scales, meat, and rare reagents.
- A dungeon farm may have an instance-reset constraint.
- A current-expansion farm may only work during a world quest or before a phase-changing quest.





Phase 2 — Add “Start This Farm”
Every mapped material, rare, instance, or curated farm should be able to start a tagged session.
Store on the session:
- farmProfileID
- routeID
- Planned mode and group size
- Active requirements snapshot
- Expected output item IDs
- Map/zone at start
- Pricing source snapshot
- Whether active-time or elapsed-time GPH was selected
At session end, calculate results specifically for that farm rather than merging every historical drop of an item.
This fixes a current modeling weakness: drop/hour is aggregated by item across sessions, even when an item has several routes with very different yields.
Acceptance criteria:
- Starting a farm never destroys an already active session without confirmation.
- A tagged farm survives /reload.
- Results remain associated with the selected route after history merge/split operations.
- The same item can have separate learned rates for separate routes.
- Untagged historical sessions continue to work.





Phase 8 — Transmog portfolio support
Do not build a second TSM. Add a focused layer over existing inventory and ATT data:
- Unique versus shared appearance signal
- Region sale rate and sold/day
- Current quantity held
- Value density
- Source dungeon/zone
- Last farmed
- Favorite farm collection
- User-configurable keep thresholds
The page-57 value/sale-rate rules can inspire an optional custom-rule editor, but they should not be hardcoded as universally correct defaults.
A useful initial result would be:
“This session produced 43 auctionable appearances: 6 strong candidates, 12 speculative candidates, and 25 below your configured threshold.”




Phase 9 — Improve learned route data
Build on the existing user-pin implementation:
- Keep mining and herbalism out of loot-location learning, as currently intended.
- Record skinning, mob-drop, cloth, meat, elemental, and similar sources.
- Cluster nearby observations into heat areas rather than showing hundreds of identical pins.
- Separate NPC/source names within the same coordinate bucket.
- Weight pins by observation count and quantity.
- Add first-seen, last-seen, and session-count confidence.
- Let the user hide, delete, or reset learned data by item and map.
- Never merge user observations into bundled static data automatically.
This directly supports the backlog idea about dynamically enriching mob-drop and skinning locations.
