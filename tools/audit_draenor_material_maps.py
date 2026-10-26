"""Export Draenor base Materials map coverage using the actual Lua catalog loader.

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
    args = parser.parse_args()
    lua = LuaRuntime(unpack_returned_tuples=True)
    ns = lua.table()
    load = lua.eval('function(path, ns) assert(loadfile(path))("GGT", ns) end')
    load('Data/FarmingItems.lua', ns)
    root = Path('Data/General-Gold-Tracker_Materials')
    module = 'MaterialFarmingSpots/Warlords/BaseMaterialMaps.lua'
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
    audit = convert(ns.DraenorBaseMaterialMapAudit)
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
            'zones': sorted({s['mapName'] for s in spots}),
            'sourceUrls': sorted({url for s in spots for url in s['sourceUrls']}),
            'locations': [{k: s[k] for k in ('id','mapID','mapName','location','farmAction','mapOnly') if k in s} for s in spots],
        })
    rows.sort(key=lambda r: (r['category'], r['itemName']))
    result = {
        'scope': audit['scope'], 'researchedAt': audit['researchedAt'],
        'itemCount': len(rows), 'coordinateItemCount': sum(r['pinCount'] > 0 for r in rows),
        'mapOptionCount': sum(r['mapOptionCount'] for r in rows),
        'uniqueCoordinateAnchors': len(unique_pins),
        'outOfScopeRecordsUnchanged': True, 'rejectedSpots': audit['rejectedSpots'], 'items': rows,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in result.items() if k not in ('items','rejectedSpots')}, indent=2))


if __name__ == '__main__':
    main()
