# Materials bait pricing — 2026-10-23

Two independent problems explain the screenshots.

1. Materials queried only the selected price source. With Min Buyout selected,
   no current auctions meant a blank value even when realm market or regional
   prices existed. Materials now uses `ResolveItemUnitValue`, the same ordered
   fallback settings as the other valuation views. Its item tooltip names the
   actual resolved source and adds `(fallback)` when applicable. An item still
   shows no price if every configured source is unavailable.
2. TSM's public custom-price API rounds expression results to whole numbers.
   A regional sale rate or sold-per-day value of 0.002 therefore became zero
   and was returned as unavailable. Regional statistics are now evaluated as
   `1000 * source`, then divided by 1000. Money sources retain their normal
   copper values. The Materials table and tooltip also retain three decimals
   for these tiny daily volumes.

Evidence from the installed TSM code:

- `TradeSkillMaster/Core/API.lua`: `GetCustomPriceValue` delegates to CustomPrice.
- `TradeSkillMaster/LibTSMTypes/Source/CustomString/Classes/Object.lua`:
  `Evaluate` rounds the final expression result.
- `TradeSkillMaster/Core/Service/AuctionDB/Core.lua`: regional demand statistics
  are stored in thousandths and divided by 1000.

The installed AppHelper snapshot for Magtheridon matches the supplied examples:

| Item | Current Min Buyout | Realm market | EU region market | EU sold/day and sale rate |
| --- | --- | --- | --- | --- |
| Jawless Skulker Bait (110274) | Absent | 120200 copper | 103891 copper | Absent |
| Blackwater Whiptail Bait (110294) | Absent | Absent | 178358 copper | 0.002 each |

These are local snapshot observations, not a claim about future live prices.

Validation covers preferred-source success, realm/regional fallback, no available
price, exact fractional statistics, deferred lookup behavior and the asynchronous
Materials refresh worker. Fallback-order changes invalidate normal and expanded
Materials caches. Live WoW tooltip/rendering verification still requires `/reload`.

The focused Materials, valuation, namespace and table-header checks passed 95
assertion cases, alongside one reproduced pre-existing UI map-order failure.
The broader catalog suite passed 114 cases with 18 failures also reproduced
without the Elemental catalog metadata. Manifest validation passed all seven
manifests and 250 runtime Lua files; changed runtime files passed Lua 5.1 parsing.
