import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
try:
    from PIL import Image
    import numpy as np
    from scipy import ndimage
except ImportError:
    Image = None
else:
    sys.path.insert(0, str(ROOT / 'tools'))
    try:
        spec = importlib.util.spec_from_file_location('map_corners', ROOT / 'tools/generate_map_corner_fills.py')
        corners = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(corners)
        from map_mask_texture import read_texture
    finally:
        sys.path.pop(0)


@unittest.skipIf(Image is None, 'Map corner checks require Pillow, NumPy and SciPy')
class MapCornerTests(unittest.TestCase):
    def test_ornament_repair_retains_native_art_hidden_by_the_frame_cut(self):
        settings = {'ornament_polygons': [[[85, 85], [127, 85], [127, 127], [85, 127]]],
                    'preserve_paths': [[[100, 90], [100, 120]]], 'preserve_width': 8}
        # A broad frame cut hides intact ocean as well as the ornament. Only
        # the reviewed ornament is replaceable; the protected depth ink stays.
        erase = corners.erasure_mask((128, 128), Image.new('L', (128, 128)),
                                     Image.new('L', (128, 128), 255), settings)
        self.assertEqual(0, erase.getpixel((65, 110)))
        self.assertEqual(255, erase.getpixel((115, 110)))
        self.assertEqual(0, erase.getpixel((100, 110)))

    def test_exported_southeast_contour_retains_native_pixels(self):
        recipe = json.loads((ROOT / 'tools/map_corner_fills.json').read_text())
        wanted = {tuple(point) for point in recipe['art']['118']['bottom-right']['preserve_probes']}
        receipt = json.loads((ROOT / 'docs/research/map-corners-2026-10-25.json').read_text())
        found = set()
        for record in receipt['art']['118']:
            texture = read_texture(ROOT / f"UI/Maps/Media/CornerFills/{record['file']}.blp")
            left, top = round(record['rect'][0] * 3840), round(record['rect'][1] * 2560)
            for probe in record.get('preserved_native_pixels', []):
                point = tuple(probe['pixel'])
                actual = texture.getpixel((point[0] - left, point[1] - top))
                self.assertEqual(255, actual[3])
                # BC3 compression can quantize native colour, but cannot
                # replace the original dark contour with generic water.
                self.assertLessEqual(max(abs(a - b) for a, b in zip(actual, probe['rgb'])), 16)
                found.add(point)
        self.assertGreaterEqual(len(wanted), 8)
        self.assertEqual(wanted, found)

    def test_support_covers_the_holes_without_touching_the_other_corners_or_center(self):
        top = corners.corner_alpha((512, 512), 'top-left')
        bottom = corners.corner_alpha((512, 512), 'bottom-right')
        self.assertEqual(255, top.getpixel((0, 0)))
        self.assertEqual(255, bottom.getpixel((511, 511)))
        for point in ((256, 256), (511, 0), (0, 511)):
            self.assertEqual(0, top.getpixel(point))
            self.assertEqual(0, bottom.getpixel(point))
        # Full coverage through the native frame's diagonal antialias fringe.
        self.assertEqual(255, top.getpixel((70, 70)))
        self.assertEqual(255, bottom.getpixel((441, 441)))

    def test_sparse_packing_preserves_pixels_and_alpha_across_tile_boundaries(self):
        size = (3840, 2560)
        painting = Image.new('RGB', size, (171, 151, 104))
        for corner in ('top-left', 'bottom-right'):
            alpha = corners.corner_alpha(size, corner)
            assembled = Image.new('RGBA', size)
            textures = list(corners.corner_tiles(painting, alpha, corner))
            self.assertEqual(2, len(textures))
            self.assertLessEqual(sum(image.width * image.height for image, _, _ in textures), 1024**2 + 256**2)
            for image, rect, uv in textures:
                self.assertLessEqual(max(image.size), 1024)
                tile = image.crop((0, 0, round(uv[1] * image.width), round(uv[3] * image.height)))
                assembled.alpha_composite(tile, (round(rect[0] * size[0]), round(rect[1] * size[1])))
            np.testing.assert_array_equal(np.asarray(alpha), np.asarray(assembled.getchannel('A')))
            visible = np.asarray(alpha) == 255
            self.assertTrue(np.all(np.asarray(assembled)[:, :, :3][visible] == (171, 151, 104)))

    def test_shipped_corner_tiles_match_their_receipt(self):
        receipt = json.loads((ROOT / 'docs/research/map-corners-2026-10-25.json').read_text())
        records = receipt['art']['118']
        self.assertEqual({'top-left', 'bottom-right'}, {record['corner'] for record in records})
        self.assertEqual(4, len(records))
        for record in records:
            path = ROOT / f"UI/Maps/Media/CornerFills/{record['file']}.blp"
            self.assertEqual(record['sha256'], hashlib.sha256(path.read_bytes()).hexdigest())
            texture = read_texture(path)
            self.assertEqual(tuple(record['texture_size']), texture.size)
            self.assertLessEqual(max(texture.size), 1024)
            self.assertEqual(0, texture.getchannel('A').getextrema()[0])
            self.assertEqual(255, texture.getchannel('A').getextrema()[1])


if __name__ == '__main__':
    unittest.main()
