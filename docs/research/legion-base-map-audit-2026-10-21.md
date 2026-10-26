# Legion base Materials map audit - 2026-10-21

Audited all 118 Legion records without recipe components: 105 visible Materials entries and 13 bound support entries that keep their existing hidden status. The 377 Composed entries and every other expansion's research record are unchanged.

The loaded catalog has 1364 map choices, up from 203. There are 1082 distinct map/coordinate anchors across 107 items. The other 11 items have explicit source-area navigation. Shared ore, herb and water locations are reused for the outputs they supply; option totals count those per-item choices.

Found and repaired 23 entries without pins, including all six uncut Argus epic gems. Each epic gem now has ten options: eight Empyrium input routes across the three Argus zones, Maras's exchange aboard the Vindicaar, and the event-only Timewalking gem delivery. Earlier uncommon/rare gems each have seventeen options. The lightweight index changes only the 23 formerly missing Legion base-map flags.

Each of the 118 items was searched individually. Current Retail Wowhead tooltip retrievals confirm item identity, while indexed item-page comments and profession guides support acquisition and locations. Identity receipts are not evidence of coordinates. Existing sourced ore/herb route payloads, coordinate order and tips are preserved; new derivative options retain their input requirements and explain prospecting, milling, bait chains or other processing.

Sources and guidance distinguish exact reported pins, habitat scouting areas, dungeon access, rotating digsites, conditional world quests and vendor trades. Navigation-only entries intentionally have no artificial coordinate. Ancient Mana consumables are distinguished from currency-only pickups; ocean bait requires the Great Sea; the shark expires after one minute. Bound legendary inputs describe their quest chains and final stations.

Validation: six focused data specs passed in embedded Lua 5.1 (Busted was unavailable). The actual Materials row and map-option builders expose Map for all 105 visible base entries; all 1364 choices open and produce tips/source detail rows. Six manifests and 238 runtime Lua files pass manifest validation; git diff whitespace checks pass. Live WoW rendering, spawns, quest availability and yields have not been tested. New or transformed source options are marked inGameTested = false.

Research artifacts:

- [Individual search queries and source links](legion-base-map-searches-2026-10-21.json)
- [Retail item identity retrieval receipts](legion-base-map-source-index-2026-10-21.json)
- [Follow-up source-chain and location research](legion-base-map-supplemental-sources-2026-10-21.json)
- [All locations, coordinates, acquisition actions, tips and source URLs](legion-base-map-coverage-2026-10-21.json)

| Item | Category | Map choices before / after | Coordinate pins | Source zones |
| --- | --- | ---: | ---: | --- |
| [Ancient Mana Crystal](https://www.wowhead.com/item=139786) | Ancient Mana Item | 2 / 5 | 2 | Suramar |
| [Ancient Mana Gem](https://www.wowhead.com/item=139890) | Ancient Mana Item | 2 / 5 | 2 | Suramar |
| [Ancient Suramar Scroll](https://www.wowhead.com/item=130903) | Archaeology Keystone | 0 / 16 | 0 | Azsuna, Suramar |
| [Highmountain Ritual-Stone](https://www.wowhead.com/item=130904) | Archaeology Keystone | 0 / 12 | 0 | Highmountain |
| [Mark of the Deceiver](https://www.wowhead.com/item=130905) | Archaeology Keystone | 0 / 23 | 0 | Azsuna, Stormheim, Val'sharah |
| [Blood of Sargeras](https://www.wowhead.com/item=124124) (bound support) | Bound Crafting Input | 1 / 57 | 645 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Bolt of Shadowcloth](https://www.wowhead.com/item=146710) (bound support) | Bound Crafting Input | 0 / 2 | 1 | Broken Shore, Suramar |
| [Bolt of Starweave](https://www.wowhead.com/item=146711) (bound support) | Bound Crafting Input | 0 / 2 | 1 | Broken Shore, Suramar |
| [Fel Piston Stabilizer](https://www.wowhead.com/item=140784) (bound support) | Bound Crafting Input | 0 / 2 | 0 | Shadowmoon Valley (Outland) |
| [Hammer of Forgotten Heroes](https://www.wowhead.com/item=146714) (bound support) | Bound Crafting Input | 0 / 2 | 0 | Broken Shore, Highmountain |
| [Hardened Circuitboard Plating](https://www.wowhead.com/item=140785) (bound support) | Bound Crafting Input | 1 / 1 | 1 | Borean Tundra |
| [Neural Net Detangler](https://www.wowhead.com/item=140782) (bound support) | Bound Crafting Input | 0 / 1 | 0 | The Storm Peaks |
| [Predictive Combat Operations Databank](https://www.wowhead.com/item=140783) (bound support) | Bound Crafting Input | 0 / 1 | 0 | Vale of Eternal Blossoms |
| [Primal Sargerite](https://www.wowhead.com/item=151568) (bound support) | Bound Crafting Input | 1 / 20 | 422 | Antoran Wastes, Eredath, Krokuun |
| [Prime Wardenscale](https://www.wowhead.com/item=146713) (bound support) | Bound Crafting Input | 0 / 2 | 1 | Azsuna, Broken Shore |
| [Wisp-Touched Elderhide](https://www.wowhead.com/item=146712) (bound support) | Bound Crafting Input | 0 / 2 | 0 | Broken Shore, Highmountain |
| [X-87 Battle Circuit](https://www.wowhead.com/item=140781) (bound support) | Bound Crafting Input | 0 / 1 | 0 | Gnomeregan |
| [Unbroken Claw](https://www.wowhead.com/item=124438) | Claw | 3 / 19 | 40 | Azsuna, Dalaran (Broken Isles), Highmountain, Krokuun, Stormheim, Suramar, Val'sharah |
| [Lightweave Cloth](https://www.wowhead.com/item=151567) | Cloth | 2 / 4 | 5 | Antoran Wastes, Eredath, Krokuun |
| [Shal'dorei Silk](https://www.wowhead.com/item=124437) | Cloth | 4 / 5 | 16 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim |
| [Falcosaur Egg](https://www.wowhead.com/item=142336) | Egg | 4 / 4 | 4 | Azsuna, Highmountain, Stormheim, Val'sharah |
| [Infernal Brimstone](https://www.wowhead.com/item=124444) | Elemental | 7 / 7 | 15 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Arkhana](https://www.wowhead.com/item=124440) | Enchanting | 3 / 10 | 18 | Dalaran (Broken Isles), Highmountain, Krokuun, Suramar, Val'sharah |
| [Chaos Crystal](https://www.wowhead.com/item=124442) | Enchanting | 1 / 4 | 4 | Dalaran (Broken Isles), Suramar, Val'sharah |
| [Leylight Shard](https://www.wowhead.com/item=124441) | Enchanting | 3 / 8 | 12 | Dalaran (Broken Isles), Highmountain, Krokuun, Suramar, Val'sharah |
| [Hardened Felglass](https://www.wowhead.com/item=144329) | Engineering Reagent | 0 / 4 | 15 | Azsuna, Highmountain, Stormheim |
| [Pristine Falcosaur Feather](https://www.wowhead.com/item=142335) | Feather | 4 / 4 | 4 | Azsuna, Highmountain, Stormheim, Val'sharah |
| [Big Fountain Goldfish](https://www.wowhead.com/item=138967) | Fish | 0 / 3 | 0 | Dalaran (Broken Isles), Dalaran Sewers |
| [Black Barracuda](https://www.wowhead.com/item=124112) | Fish | 1 / 10 | 5 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Cursed Queenfish](https://www.wowhead.com/item=124107) | Fish | 1 / 10 | 10 | Azsuna, Dalaran (Broken Isles) |
| [Highmountain Salmon](https://www.wowhead.com/item=124109) | Fish | 1 / 10 | 10 | Dalaran (Broken Isles), Highmountain |
| [Mossgill Perch](https://www.wowhead.com/item=124108) | Fish | 1 / 11 | 11 | Dalaran (Broken Isles), Val'sharah |
| [Runescale Koi](https://www.wowhead.com/item=124111) | Fish | 1 / 12 | 12 | Dalaran (Broken Isles), Suramar |
| [Silver Mackerel](https://www.wowhead.com/item=133607) | Fish | 1 / 10 | 5 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Stormray](https://www.wowhead.com/item=124110) | Fish | 1 / 12 | 12 | Dalaran (Broken Isles), Stormheim |
| [Ancient Vrykul Ring](https://www.wowhead.com/item=133715) | Fishing Bait | 1 / 11 | 11 | Stormheim |
| [Aromatic Murloc Slime](https://www.wowhead.com/item=133702) | Fishing Bait | 1 / 9 | 9 | Azsuna |
| [Axefish Lure](https://www.wowhead.com/item=133722) | Fishing Bait | 1 / 9 | 4 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Decayed Whale Blubber](https://www.wowhead.com/item=133724) | Fishing Bait | 1 / 9 | 4 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Demonic Detritus](https://www.wowhead.com/item=133720) | Fishing Bait | 1 / 11 | 11 | Suramar |
| [Drowned Thistleleaf](https://www.wowhead.com/item=133708) | Fishing Bait | 1 / 10 | 10 | Val'sharah |
| [Enchanted Lure](https://www.wowhead.com/item=133717) | Fishing Bait | 1 / 11 | 11 | Suramar |
| [Frost Worm](https://www.wowhead.com/item=133712) | Fishing Bait | 1 / 9 | 9 | Highmountain |
| [Funky Sea Snail](https://www.wowhead.com/item=133709) | Fishing Bait | 1 / 9 | 9 | Highmountain |
| [Message in a Beer Bottle](https://www.wowhead.com/item=133721) | Fishing Bait | 1 / 9 | 4 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Moosehorn Hook](https://www.wowhead.com/item=133713) | Fishing Bait | 1 / 11 | 11 | Stormheim |
| [Nightmare Nightcrawler](https://www.wowhead.com/item=133707) | Fishing Bait | 1 / 10 | 10 | Val'sharah |
| [Pearlescent Conch](https://www.wowhead.com/item=133703) | Fishing Bait | 1 / 9 | 9 | Azsuna |
| [Ravenous Fly](https://www.wowhead.com/item=133795) | Fishing Bait | 1 / 9 | 4 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Rotten Fishbone](https://www.wowhead.com/item=133705) | Fishing Bait | 1 / 10 | 10 | Val'sharah |
| [Rusty Queenfish Brooch](https://www.wowhead.com/item=133704) | Fishing Bait | 1 / 9 | 9 | Azsuna |
| [Salmon Lure](https://www.wowhead.com/item=133710) | Fishing Bait | 1 / 9 | 9 | Highmountain |
| [Silverscale Minnow](https://www.wowhead.com/item=133714) | Fishing Bait | 1 / 11 | 11 | Stormheim |
| [Skrog Toenail](https://www.wowhead.com/item=133701) | Fishing Bait | 1 / 9 | 9 | Azsuna |
| [Sleeping Murloc](https://www.wowhead.com/item=133719) | Fishing Bait | 1 / 11 | 11 | Suramar |
| [Soggy Drakescale](https://www.wowhead.com/item=133716) | Fishing Bait | 1 / 11 | 11 | Stormheim |
| [Stunned, Angry Shark](https://www.wowhead.com/item=133723) | Fishing Bait | 1 / 9 | 4 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Swollen Murloc Egg](https://www.wowhead.com/item=133711) | Fishing Bait | 1 / 9 | 9 | Highmountain |
| [Deck Sandals](https://www.wowhead.com/item=139408) | Fishing Transmog | 1 / 59 | 54 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Diver's Chain Boots](https://www.wowhead.com/item=139407) | Fishing Transmog | 1 / 59 | 54 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Kul'Tiras Marine Issue Boots](https://www.wowhead.com/item=139405) | Fishing Transmog | 1 / 59 | 54 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Sea Dog Boots](https://www.wowhead.com/item=139406) | Fishing Transmog | 1 / 59 | 54 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Argulite](https://www.wowhead.com/item=151718) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Azsunite](https://www.wowhead.com/item=130174) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Chaotic Spinel](https://www.wowhead.com/item=130175) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Chemirine](https://www.wowhead.com/item=151720) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Dawnlight](https://www.wowhead.com/item=130180) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Deep Amber](https://www.wowhead.com/item=130173) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Eye of Prophecy](https://www.wowhead.com/item=130179) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Florid Malachite](https://www.wowhead.com/item=151722) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Furystone](https://www.wowhead.com/item=130178) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Hesselian](https://www.wowhead.com/item=151721) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Labradorite](https://www.wowhead.com/item=151579) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Lightsphene](https://www.wowhead.com/item=151719) | Gem | 0 / 10 | 277 | Antoran Wastes, Dalaran (Broken Isles), Eredath, Krokuun |
| [Maelstrom Sapphire](https://www.wowhead.com/item=130182) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Pandemonite](https://www.wowhead.com/item=130181) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Queen's Opal](https://www.wowhead.com/item=130177) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Sangrite](https://www.wowhead.com/item=130172) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Shadowruby](https://www.wowhead.com/item=130183) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Skystone](https://www.wowhead.com/item=130176) | Gem | 2 / 17 | 312 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Gem Chip](https://www.wowhead.com/item=129100) | Gem Chip | 2 / 26 | 607 | Antoran Wastes, Azsuna, Eredath, Highmountain, Krokuun, Stormheim, Suramar, Val'sharah |
| [Aethril](https://www.wowhead.com/item=124101) | Herb | 5 / 6 | 55 | Azsuna, Dalaran (Broken Isles) |
| [Astral Glory](https://www.wowhead.com/item=151565) | Herb | 8 / 9 | 128 | Antoran Wastes, Eredath, Krokuun |
| [Dreamleaf](https://www.wowhead.com/item=124102) | Herb | 5 / 6 | 69 | Dalaran (Broken Isles), Val'sharah |
| [Felwort](https://www.wowhead.com/item=124106) | Herb | 5 / 5 | 17 | Azsuna, Highmountain |
| [Fjarnskaggl](https://www.wowhead.com/item=124104) | Herb | 5 / 6 | 60 | Dalaran (Broken Isles), Stormheim |
| [Foxflower](https://www.wowhead.com/item=124103) | Herb | 5 / 6 | 65 | Dalaran (Broken Isles), Highmountain |
| [Starlight Rose](https://www.wowhead.com/item=124105) | Herb | 5 / 6 | 57 | Dalaran (Broken Isles), Suramar |
| [Felhide](https://www.wowhead.com/item=124116) | Hide | 2 / 12 | 13 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Fiendish Leather](https://www.wowhead.com/item=151566) | Leather | 3 / 4 | 12 | Eredath, Krokuun |
| [Stonehide Leather](https://www.wowhead.com/item=124113) | Leather | 3 / 8 | 15 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar |
| [Stormscale](https://www.wowhead.com/item=124115) | Leather | 3 / 9 | 16 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Big Gamy Ribs](https://www.wowhead.com/item=124119) | Meat | 1 / 6 | 6 | Dalaran (Broken Isles), Highmountain, Stormheim, Val'sharah |
| [Fatty Bearsteak](https://www.wowhead.com/item=124118) | Meat | 2 / 4 | 7 | Dalaran (Broken Isles), Highmountain, Stormheim |
| [Lean Shank](https://www.wowhead.com/item=124117) | Meat | 2 / 4 | 9 | Azsuna, Dalaran (Broken Isles), Highmountain, Suramar |
| [Leyblood](https://www.wowhead.com/item=124120) | Meat | 2 / 6 | 8 | Azsuna, Dalaran (Broken Isles), Suramar |
| [Slice of Bacon](https://www.wowhead.com/item=133680) | Meat | 1 / 5 | 0 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Wildfowl Egg](https://www.wowhead.com/item=124121) | Meat | 2 / 4 | 8 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim |
| [Empyrium](https://www.wowhead.com/item=151564) | Ore | 8 / 9 | 276 | Antoran Wastes, Eredath, Krokuun |
| [Felslate](https://www.wowhead.com/item=123919) | Ore | 9 / 10 | 213 | Azsuna, Dalaran (Broken Isles), Highmountain, Stormheim, Suramar, Val'sharah |
| [Leystone Ore](https://www.wowhead.com/item=123918) | Ore | 7 / 8 | 100 | Azsuna, Dalaran (Broken Isles), Suramar, Val'sharah |
| [Roseate Pigment](https://www.wowhead.com/item=129032) | Pigment | 0 / 38 | 446 | Antoran Wastes, Azsuna, Eredath, Highmountain, Krokuun, Stormheim, Suramar, Val'sharah |
| [Sallow Pigment](https://www.wowhead.com/item=129034) | Pigment | 0 / 38 | 446 | Antoran Wastes, Azsuna, Eredath, Highmountain, Krokuun, Stormheim, Suramar, Val'sharah |
| [Aethril Seed](https://www.wowhead.com/item=129284) | Seed | 1 / 6 | 60 | Azsuna |
| [Dreamleaf Seed](https://www.wowhead.com/item=129285) | Seed | 1 / 6 | 82 | Val'sharah |
| [Felwort Seed](https://www.wowhead.com/item=129289) | Seed | 2 / 7 | 19 | Azsuna, Highmountain |
| [Fjarnskaggl Seed](https://www.wowhead.com/item=129287) | Seed | 1 / 6 | 65 | Stormheim |
| [Foxflower Seed](https://www.wowhead.com/item=129286) | Seed | 1 / 6 | 70 | Highmountain |
| [Starlight Rose Seed](https://www.wowhead.com/item=129288) | Seed | 1 / 6 | 61 | Suramar |
| [Yseralline Seed](https://www.wowhead.com/item=128304) | Seed | 6 / 31 | 352 | Azsuna, Highmountain, Stormheim, Suramar, Val'sharah |
| [Unbroken Tooth](https://www.wowhead.com/item=124439) | Tooth | 3 / 19 | 40 | Azsuna, Dalaran (Broken Isles), Highmountain, Krokuun, Stormheim, Suramar, Val'sharah |
| [Dalapeno Pepper](https://www.wowhead.com/item=133589) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [Flaked Sea Salt](https://www.wowhead.com/item=133588) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [Muskenbutter](https://www.wowhead.com/item=133590) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [River Onion](https://www.wowhead.com/item=133591) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [Royal Olive](https://www.wowhead.com/item=133593) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [Stonedark Snail](https://www.wowhead.com/item=133592) | Vendor | 1 / 2 | 2 | Dalaran (Broken Isles) |
| [Fel-Touched Lumber](https://www.wowhead.com/item=251767) (bound support) | Warband Housing Lumber | 0 / 5 | 1 | Azsuna, Broken Shore, Highmountain, Suramar, Val'sharah |
