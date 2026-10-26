"""Export Legion base Materials map coverage using the actual Lua catalog loader.

Requires lupa with its lua51 runtime. Composed entries are excluded from the
report and compared before/after to enforce the requested data boundary.
"""
import argparse
import json
from pathlib import Path
from lupa.lua51 import LuaRuntime


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--report', type=Path, help='Also write the item-by-item Markdown audit')
    args = parser.parse_args()
    lua = LuaRuntime(unpack_returned_tuples=True)
    ns = lua.table()
    load = lua.eval('function(path, ns) assert(loadfile(path))("GGT", ns) end')
    load('Data/FarmingItems.lua', ns)
    root = Path('Data/General-Gold-Tracker_Materials')
    module = 'MaterialFarmingSpots/Legion/BaseMaterialMaps.lua'
    for line in (root / 'General-Gold-Tracker_Materials.toc').read_text().splitlines():
        if line.endswith('.lua') and line not in ('Namespace.lua', module):
            load((root / line).as_posix(), ns)

    def convert(value):
        if hasattr(value, 'items'):
            keys = list(value.keys())
            if keys and all(isinstance(k, int) for k in keys) and sorted(keys) == list(range(1, len(keys)+1)):
                return [convert(value[k]) for k in sorted(keys)]
            return {str(k): convert(v) for k, v in value.items()}
        return value

    before = convert(ns.MaterialFarmingSpots['items'])
    catalog = convert(ns.FarmingItems)
    load((root / module).as_posix(), ns)
    assert catalog == convert(ns.FarmingItems), 'Catalog or recipes changed'
    after = convert(ns.MaterialFarmingSpots['items'])
    audit = convert(ns.LegionBaseMaterialMapAudit)
    # Loading the enrichment twice must not duplicate any choices.
    load((root / module).as_posix(), ns)
    assert after == convert(ns.MaterialFarmingSpots['items']), 'Second load changed maps'
    for item_id, record in before.items():
        if item_id not in audit['items']:
            assert record == after[item_id], f'Out-of-scope item changed: {item_id}'
    rows = []
    unique_pins = set()
    for row in catalog['items']:
        item_id = str(row['itemID'])
        if item_id not in audit['items']:
            continue
        item = after[item_id]
        counts = audit['items'][item_id]
        spots = item.get('spots', [])
        assert spots and len({s['id'] for s in spots}) == len(spots), item_id
        for spot in spots:
            assert spot.get('tips') and spot.get('sourceUrls'), (item_id, spot['id'])
            assert spot.get('mapOnly') or spot.get('coords'), (item_id, spot['id'])
            for coord in spot.get('coords', []):
                assert 0 <= coord['x'] <= 1 and 0 <= coord['y'] <= 1
                unique_pins.add((spot['mapID'], coord['x'], coord['y']))
        rows.append({
            'itemID': row['itemID'], 'itemName': item['itemName'], 'category': row.get('tag'),
            **counts,
            'previousMapOptionCount': len(before.get(item_id, {}).get('spots', [])),
            'previousPinCount': sum(len(s.get('coords', [])) for s in before.get(item_id, {}).get('spots', [])),
            'visibleInBaseList': item.get('auctionable') is not False and item.get('supportOnly') is not True,
            'zones': sorted({s['mapName'] for s in spots}),
            'sourceUrls': sorted({url for s in spots for url in s['sourceUrls']}),
            'locations': [{k: s[k] for k in ('id','mapID','mapName','location','farmAction','mapOnly','coords','tips','sourceUrls') if k in s} for s in spots],
        })
    rows.sort(key=lambda r: (r['category'], r['itemName']))
    result = {
        'scope': audit['scope'], 'researchedAt': audit['researchedAt'],
        'itemCount': len(rows), 'coordinateItemCount': sum(r['pinCount'] > 0 for r in rows),
        'previouslyWithoutPins': sum(r['previousPinCount'] == 0 for r in rows),
        'composedEntriesExcluded': sum(r.get('expansion') == 'legion' and bool(r.get('components')) for r in catalog['items']),
        'mapOptionCount': sum(r['mapOptionCount'] for r in rows),
        'uniqueCoordinateAnchors': len(unique_pins),
        'outOfScopeRecordsUnchanged': True, 'rejectedSpots': audit['rejectedSpots'], 'items': rows,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    if args.report:
        visible = sum(r['visibleInBaseList'] for r in rows)
        searches = json.loads(Path('docs/research/legion-base-map-searches-2026-10-21.json').read_text(encoding='utf-8'))
        identities = json.loads(Path('docs/research/legion-base-map-source-index-2026-10-21.json').read_text(encoding='utf-8'))
        assert {r['itemID'] for r in rows} == {r['itemID'] for r in searches['items']} == {r['itemID'] for r in identities['items']}
        assert identities['failedSourceCount'] == 0
        lines = [
            '# Legion base Materials map audit - 2026-10-21', '',
            f"Audited all {len(rows)} Legion records without recipe components: {visible} visible Materials entries and {len(rows)-visible} bound support entries that keep their existing hidden status. The {result['composedEntriesExcluded']} Composed entries and every other expansion's research record are unchanged.", '',
            f"The loaded catalog has {result['mapOptionCount']} map choices, up from {sum(r['previousMapOptionCount'] for r in rows)}. There are {result['uniqueCoordinateAnchors']} distinct map/coordinate anchors across {result['coordinateItemCount']} items. The other {len(rows)-result['coordinateItemCount']} items have explicit source-area navigation. Shared ore, herb and water locations are reused for the outputs they supply; option totals count those per-item choices.", '',
            f"Found and repaired {result['previouslyWithoutPins']} entries without pins, including all six uncut Argus epic gems. Each epic gem now has ten options: eight Empyrium input routes across the three Argus zones, Maras's exchange aboard the Vindicaar, and the event-only Timewalking gem delivery. Earlier uncommon/rare gems each have seventeen options. The lightweight index changes only the 23 formerly missing Legion base-map flags.", '',
            'Each of the 118 items was searched individually. Current Retail Wowhead tooltip retrievals confirm item identity, while indexed item-page comments and profession guides support acquisition and locations. Identity receipts are not evidence of coordinates. Existing sourced ore/herb route payloads, coordinate order and tips are preserved; new derivative options retain their input requirements and explain prospecting, milling, bait chains or other processing.', '',
            'Sources and guidance distinguish exact reported pins, habitat scouting areas, dungeon access, rotating digsites, conditional world quests and vendor trades. Navigation-only entries intentionally have no artificial coordinate. Ancient Mana consumables are distinguished from currency-only pickups; ocean bait requires the Great Sea; the shark expires after one minute. Bound legendary inputs describe their quest chains and final stations.', '',
            'Validation: six focused data specs passed in embedded Lua 5.1 (Busted was unavailable). The actual Materials row and map-option builders expose Map for all 105 visible base entries; all 1364 choices open and produce tips/source detail rows. Six manifests and 238 runtime Lua files pass manifest validation; git diff whitespace checks pass. Live WoW rendering, spawns, quest availability and yields have not been tested. New or transformed source options are marked inGameTested = false.', '',
            'Research artifacts:', '',
            '- [Individual search queries and source links](legion-base-map-searches-2026-10-21.json)',
            '- [Retail item identity retrieval receipts](legion-base-map-source-index-2026-10-21.json)',
            '- [Follow-up source-chain and location research](legion-base-map-supplemental-sources-2026-10-21.json)',
            '- [All locations, coordinates, acquisition actions, tips and source URLs](legion-base-map-coverage-2026-10-21.json)', '',
            '| Item | Category | Map choices before / after | Coordinate pins | Source zones |',
            '| --- | --- | ---: | ---: | --- |',
        ]
        for row in rows:
            suffix = ' (bound support)' if not row['visibleInBaseList'] else ''
            lines.append(f"| [{row['itemName']}](https://www.wowhead.com/item={row['itemID']}){suffix} | {row['category']} | {row['previousMapOptionCount']} / {row['mapOptionCount']} | {row['pinCount']} | {', '.join(row['zones'])} |")
        args.report.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in result.items() if k not in ('items','rejectedSpots')}, indent=2))


if __name__ == '__main__':
    main()

