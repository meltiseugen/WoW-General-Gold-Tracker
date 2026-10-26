"""Products intentionally omitted from GGT's generated farming catalogs."""

import json
from pathlib import Path

# Named cards often lack 'Darkmoon' in their name. Keep their IDs, decks,
# sigils and deck rewards excluded when refreshing the upstream snapshots.
_POLICY = json.loads(Path(__file__).with_suffix(".json").read_text(encoding="utf-8"))
DARKMOON_ITEM_RANGES = _POLICY["darkmoonItemRanges"]
DARKMOON_ITEM_IDS = frozenset(
    item_id for first, last in DARKMOON_ITEM_RANGES for item_id in range(first, last + 1)
)
DARKMOON_PET_IDS = frozenset(_POLICY["darkmoonPetIDs"])
DARKMOON_NPC_IDS = frozenset(_POLICY["darkmoonNpcIDs"])
AUGMENT_RUNE_ITEM_IDS = frozenset(_POLICY["augmentRuneItemIDs"])
EXCLUDED_ITEM_IDS = DARKMOON_ITEM_IDS | AUGMENT_RUNE_ITEM_IDS


def excluded_product(row: dict) -> bool:
    return (
        any(row.get(key) in EXCLUDED_ITEM_IDS for key in ("item_id", "primary_item_id"))
        or row.get("pet_id") in DARKMOON_PET_IDS
        or any("darkmoon" in str(row.get(key, "")).lower()
               for key in ("name", "farm_name", "farm_id", "provider_farm_id"))
        or any("augment rune" in str(row.get(key, "")).lower().replace("-", " ")
               for key in ("name", "farm_name", "farm_id", "provider_farm_id"))
    )
