"""Refresh public Retail evidence for a base-material map inventory.

Input is the exported base catalog inventory or a previous source index. Raw
responses stay in a resumable local cache; the output contains source receipts
and factual IDs, names and reagent quantities, rather than copied guide text.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import time
import urllib.request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--expansion", choices=("pandaria", "draenor", "legion"), required=True)
    parser.add_argument("--inventory", type=Path, required=True)
    parser.add_argument("--cache", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--refresh", action="store_true", help="Retrieve sources again instead of reusing cached responses")
    args = parser.parse_args()
    inventory = json.loads(args.inventory.read_text(encoding="utf-8-sig"))
    items = [row for row in inventory["items"] if not row.get("components")]
    def source_keys(row):
        keys = [f"item:{row['itemID']}"]
        for field in ("recipeSpellID", "sourceSpellID"):
            if row.get(field):
                keys.append(f"spell:{row[field]}")
        keys.extend(row.get("sourceKeys", []))
        return list(dict.fromkeys(keys))

    tasks = {
        (kind, int(source_id))
        for row in items
        for kind, source_id in (key.split(":", 1) for key in source_keys(row))
    }
    args.cache.mkdir(parents=True, exist_ok=True)

    def fetch(task):
        kind, source_id = task
        cache_file = args.cache / f"{kind}-{source_id}.json"
        api_url = f"https://nether.wowhead.com/tooltip/{kind}/{source_id}?dataEnv=1&locale=0"
        page_url = f"https://www.wowhead.com/{kind}={source_id}"
        error = None
        for attempt in range(4):
            try:
                if cache_file.exists() and not args.refresh:
                    raw = cache_file.read_bytes()
                else:
                    request = urllib.request.Request(api_url, headers={"User-Agent": "GGT-Public-Research/1.0"})
                    with urllib.request.urlopen(request, timeout=35) as response:
                        raw = response.read()
                    payload = json.loads(raw)
                    if not payload.get("name") or not payload.get("tooltip"):
                        raise ValueError("Source returned no item/spell tooltip")
                    cache_file.write_bytes(raw)
                payload = json.loads(raw)
                result = {
                    "kind": kind, "id": source_id, "name": payload["name"],
                    "pageUrl": page_url, "retrievalUrl": api_url,
                    "retrievedAt": datetime.fromtimestamp(cache_file.stat().st_mtime, timezone.utc).isoformat(),
                    "sha256": hashlib.sha256(raw).hexdigest(), "status": "retrieved",
                }
                if kind == "spell":
                    match = re.search(r"Reagents:.*?<div[^>]*>(.*?)</div>", payload["tooltip"])
                    result["reagents"] = [
                        {"itemID": int(item_id), "quantity": int(quantity or 1)}
                        for item_id, quantity in re.findall(
                            r'<a href="/item=(\d+)[^"]*">.*?</a>(?:&nbsp;)?(?:\s*\((\d+)\))?',
                            match[1] if match else "",
                        )
                    ]
                return f"{kind}:{source_id}", result
            except (OSError, ValueError, KeyError) as exc:
                error = f"{type(exc).__name__}: {exc}"
                time.sleep(min(2 ** attempt, 8))
        return f"{kind}:{source_id}", {
            "kind": kind, "id": source_id, "pageUrl": page_url,
            "retrievalUrl": api_url, "status": "failed", "error": error,
        }

    print(f"Checking {len(items)} base items; {len(tasks)} item/source-recipe pages. Composed materials excluded.", flush=True)
    receipts = {}
    with ThreadPoolExecutor(max_workers=4) as pool:
        futures = [pool.submit(fetch, task) for task in sorted(tasks)]
        for count, future in enumerate(as_completed(futures), 1):
            key, receipt = future.result()
            receipts[key] = receipt
            if count % 50 == 0 or count == len(tasks):
                failures = sum(row["status"] == "failed" for row in receipts.values())
                print(f"Sources {count}/{len(tasks)}; failures {failures}.", flush=True)
    rows = []
    for item in items:
        keys = source_keys(item)
        rows.append({
            "itemID": item["itemID"], "itemName": receipts[keys[0]].get("name", item.get("itemName")),
            "category": item.get("tag", item.get("category")), "sourceKeys": keys,
            "status": "retrieved" if all(receipts[key]["status"] == "retrieved" for key in keys) else "incomplete",
        })
    result = {
        "scope": f"Retail {args.expansion.title()} base Materials only; composed materials excluded",
        "checkedAt": datetime.now(timezone.utc).isoformat(),
        "itemCount": len(rows), "sourceCount": len(receipts),
        "failedSourceCount": sum(row["status"] == "failed" for row in receipts.values()),
        "items": rows, "sources": dict(sorted(receipts.items())),
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {args.output}", flush=True)
    return 1 if result["failedSourceCount"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
