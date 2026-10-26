"""Eligibility contracts for the Cosmetics import (run with Python + lupa)."""
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from research_cosmetic_catalog import classify


class CosmeticEligibilityTests(unittest.TestCase):
    def test_requires_the_exact_tooltip_label(self):
        for tooltip in (
            '<span class="whtt-transmogrified-to">Cosmetic</span> Binds when equipped',
            '<span class="q7 whtt-transmogrified-to">Cosmetic</span> Binds when used',
        ):
            self.assertEqual("include", classify({"tooltip": tooltip})["decision"])
        for tooltip in (
            'Cosmetic appearance. Binds when equipped',
            '<span class="whtt-transmogrified-to">Cloth</span> Binds when equipped',
            '<span class="whtt-transmogrified-to">Cosmetic Equipment</span>',
            'Use: Learn this appearance. Binds when used',
        ):
            self.assertEqual("exclude-not-cosmetic", classify({"tooltip": tooltip})["decision"])

    def test_rejects_bound_cosmetic_rewards(self):
        for binding in ("Binds when picked up", "Binds to Warband", "Binds to account",
                        "Binds to Battle.net account", "Soulbound", "Quest Item"):
            tooltip = '<span class="whtt-transmogrified-to">Cosmetic</span> ' + binding
            self.assertEqual("exclude-bound", classify({"tooltip": tooltip})["decision"])

    def test_portable_import_contains_every_verified_eligible_item_once(self):
        audit = json.loads(Path("docs/research/cosmetic-type-audit-2026-10-23.json").read_text(encoding="utf-8"))
        source = json.loads(Path("docs/research/cosmetic-source-index-2026-10-23.json").read_text(encoding="utf-8"))
        eligible = {int(key) for key, row in audit["items"].items() if row["decision"] == "include"}
        selected = [row["itemID"] for row in source["items"]]
        self.assertEqual(eligible, set(selected))
        self.assertEqual(len(eligible), len(selected))
        for item in source["items"]:
            receipt = audit["items"][str(item["itemID"])]
            self.assertTrue(receipt["cosmeticTooltipType"] and receipt["auctionable"])
            self.assertEqual("retrieved", receipt["status"])
            self.assertEqual(64, len(receipt["sha256"]))
            self.assertTrue(item["origins"])
            for origin in item["origins"]:
                self.assertTrue(origin["details"])
                self.assertTrue(origin["expansion"] and origin["patch"])
                if origin["provider"] == "TODO-Planner":
                    self.assertTrue(origin["sourceFile"].startswith("Data/Expansions/"))


if __name__ == "__main__":
    unittest.main()
