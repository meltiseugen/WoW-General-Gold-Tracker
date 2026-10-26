import importlib.util
import json
import struct
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("map_terrain", ROOT / "tools/generate_map_terrain.py")
terrain = importlib.util.module_from_spec(spec)
spec.loader.exec_module(terrain)
mask_spec = importlib.util.spec_from_file_location("map_mask", ROOT / "tools/generate_map_edge_mask.py")
mask = importlib.util.module_from_spec(mask_spec)
mask_spec.loader.exec_module(mask)


class MapTerrainTests(unittest.TestCase):
    def test_wdt_uses_row_major_records_and_excludes_inactive_and_empty_tiles(self):
        main, maid = bytearray(4096 * 8), bytearray(4096 * 32)
        for col, row, fid, active in [(7, 36, 123456, 1), (8, 36, 123457, 0), (9, 36, 0, 1)]:
            index = row * 64 + col
            struct.pack_into("<I", main, index * 8, active)
            struct.pack_into("<I", maid, index * 32 + 28, fid)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "test.wdt"
            path.write_bytes(b"NIAM" + struct.pack("<I", len(main)) + main + b"DIAM" + struct.pack("<I", len(maid)) + maid)
            self.assertEqual({7 * 64 + 36: 123456}, terrain.active_tiles(path))

    def test_rejects_truncated_and_incomplete_manifests(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "test.wdt"
            path.write_bytes(b"DIAM" + struct.pack("<I", 1024) + b"short")
            with self.assertRaisesRegex(ValueError, "Truncated"):
                terrain.active_tiles(path)
            path.write_bytes(b"NIAM" + struct.pack("<I", 0))
            with self.assertRaisesRegex(ValueError, "complete"):
                terrain.active_tiles(path)

    def test_shipped_coverage_has_pinned_native_manifests_for_expansion_worlds(self):
        receipt = json.loads((ROOT / "docs/research/map-terrain-2026-10-24.json").read_text())
        for map_id in (0, 1, 530, 571, 870, 1116, 1220, 1642, 1643, 2222, 2444, 2552, 2601):
            self.assertGreater(receipt["maps"][str(map_id)], 100)
        self.assertEqual(188, len(receipt["wdt_sha256"]))
        self.assertEqual(sum(receipt["maps"].values()), receipt["tile_count"])
        self.assertTrue(all(len(h) == 64 for h in receipt["wdt_sha256"].values()))
        self.assertIn("build=12.1.5.70529", receipt["wdt_url_template"])

    def test_own_feather_mask_is_reproducible_symmetric_and_has_opaque_center(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "mask.tga"
            mask.generate(path)
            data = path.read_bytes()
            self.assertEqual((ROOT / "UI/Maps/Media/EdgeFade.tga").read_bytes(), data)
            alpha = data[21::4]
            self.assertEqual(128 * 128, len(alpha))
            self.assertEqual(255, alpha[64 * 128 + 64])
            self.assertLess(alpha[0], 8)
            self.assertEqual(alpha, alpha[::-1])

    def test_revealed_overlay_metadata_preserves_tile_positions_without_discovery_data(self):
        with tempfile.TemporaryDirectory() as directory:
            tiles = Path(directory) / "WorldMapOverlayTile.csv"
            tiles.write_text("WorldMapOverlayID,RowIndex,ColIndex,LayerIndex,FileDataID\n"
                             "1,1,1,0,987\n1,0,0,0,654\n1,0,1,1,999\n", encoding="utf-8")
            overlays = [{"ID": "1", "UiMapArtID": "200", "TextureWidth": "300", "TextureHeight": "270", "OffsetX": "-10", "OffsetY": "20"}]
            self.assertEqual({200: "300,270,-10,20|0:0:654,1:1:987"}, terrain.revealed_overlays(overlays, tiles))
        receipt = json.loads((ROOT / "docs/research/map-terrain-2026-10-24.json").read_text())
        self.assertEqual(receipt["fog_art_count"], receipt["revealed_art_count"])


if __name__ == "__main__":
    unittest.main()
