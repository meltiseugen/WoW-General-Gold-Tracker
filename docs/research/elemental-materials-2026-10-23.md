# Elemental Materials review — 2026-10-23

Elemental is an additional Materials browsing filter. Existing profession memberships,
expansion selection, raid/composed groups and auctionability exclusions still apply.
Membership uses explicit item IDs in `FarmingItems.elementalItemIDs`, independent of
localized names, recipe inputs or item-cache availability.

| Expansion | Included catalog families / review outcome |
| --- | --- |
| Classic | Elemental Air/Earth/Fire/Water, Breath/Core/Globe/Heart intermediates, six elemental essences |
| Burning Crusade | Seven Mote/Primal pairs, Primal Might, Primal Nether, Nether Vortex |
| Wrath | Six Crystallized/Eternal pairs |
| Cataclysm | Five Volatiles |
| Mists | Mote and Spirit of Harmony |
| Warlords | Four Sorcerous elements; Primal Spirit remains a hidden bound input |
| Legion | Infernal Brimstone (already tagged Elemental in this catalog); Blood of Sargeras and Primal Sargerite remain hidden bound inputs |
| Battle for Azeroth | Expulsom, Hydrocore, Sanguicell, Breath of Bwonsamdi, Tidalcore are bound inputs; no eligible standalone rows |
| Shadowlands | Korthite Crystal and Progenitor Essentia; prospecting and enchanting essences retain their own categories |
| Dragonflight | Seven Rousing/Awakened pairs; four elemental souls remain hidden bound inputs |
| The War Within | No eligible elemental family in the current catalog; Crystalline Powder is Other, and seasonal sparks are outside this AH-materials list |
| Midnight | Motes of Light, Primal Energy, Wild Magic and Pure Void |

No unrelated crafted goods are included just for containing words such as Primal,
Eternal, Spirit, or Elemental. Combinations/transmutes retain their existing
Composed materials placement.

Sources consulted:

- [WoWDB: Elemental trade goods](https://www.wowdb.com/items/trade-goods/elemental): family classification, including bound expansion reagents.
- [WoW Professions: Elemental farming](https://www.wow-professions.com/farming/elementals): Classic through Pandaria families.
- [WoWDB: Crystalline Powder](https://www.wowdb.com/items/213610-crystalline-powder): classified as Other, rather than Elemental.
- [Wowhead: Midnight Mining](https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools): Midnight gathering motes; cross-checked against the existing item/recipe catalog (236949–236952).

The expansion/filter matrix contains 75 eligible auctionable items. The generated
7,365-item material index remained byte-for-byte unchanged after regeneration.
Lua 5.1 parsing and addon manifest validation passed. The existing UI map-order
failure and 18 catalog/map failures were reproduced against their earlier state.
Validation is headless/static; live WoW rendering and `/reload` verification remain separate.
