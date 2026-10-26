"""Fetch version-pinned Blizzard map manifests used by generate_map_terrain.py.

Run explicitly from the command line; this is never invoked by the addon.
"""
from __future__ import annotations

import argparse
import csv
import json
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


def fetch(build: str, map_csv: Path, candidate_receipt: Path, output: Path) -> None:
    candidates = set(json.loads(candidate_receipt.read_text(encoding="utf-8"))["maps"])
    with map_csv.open(encoding="utf-8-sig", newline="") as handle:
        maps = [r for r in csv.DictReader(handle) if r["ID"] in candidates]
    output.mkdir(parents=True, exist_ok=True)

    def download(row):
        fid = int(row["WdtFileDataID"])
        target = output / f"{fid}.wdt"
        if target.exists():
            return
        request = urllib.request.Request(f"https://wago.tools/api/casc/{fid}?build={build}", headers={"User-Agent": "GGT-map-metadata/1.0"})
        with urllib.request.urlopen(request, timeout=40) as response:
            data = response.read()
        if data[:4] != b"REVM":
            raise ValueError(f"Not a WDT: {row['ID']} ({fid})")
        target.write_bytes(data)

    with ThreadPoolExecutor(max_workers=4) as pool:
        list(pool.map(download, maps))
    print(f"Cached {len(maps)} build {build} WDT manifests in {output}")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--build", required=True)
    p.add_argument("--map-csv", type=Path, required=True)
    p.add_argument("--candidate-receipt", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    fetch(a.build, a.map_csv, a.candidate_receipt, a.output)
