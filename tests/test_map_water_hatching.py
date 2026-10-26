import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
try:
    import numpy as np
    from PIL import Image, ImageDraw
    from scipy import ndimage
except ImportError:
    Image = None
else:
    sys.path.insert(0, str(ROOT / 'tools'))
    try:
        spec = importlib.util.spec_from_file_location('water_hatching', ROOT / 'tools/generate_map_water_hatching.py')
        water = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(water)
        from map_mask_texture import read_texture
    finally:
        sys.path.pop(0)


@unittest.skipIf(Image is None, 'Water hatch checks require Pillow, NumPy and SciPy')
class MapWaterHatchingTests(unittest.TestCase):
    def test_band_keeps_land_islands_and_both_contours_untouched(self):
        image = Image.new('RGB', (128, 128), (165, 160, 120))
        ImageDraw.Draw(image).ellipse((91, 55, 99, 65), fill=(100, 70, 35))
        settings = {'reference_size': [128, 128], 'outer': [[10, 10], [118, 10], [118, 118], [10, 118]],
                    'land': [[40, 40], [80, 40], [80, 80], [40, 80]], 'feather': 8}
        mask = water.water_band(image, settings)
        for point in ((4, 60), (10, 60), (60, 60), (40, 60), (95, 60)):
            self.assertEqual(0, mask.getpixel(point), point)
        self.assertEqual(255, mask.getpixel((26, 60)))

    def test_hatch_ink_stays_fine_horizontal_and_deterministic(self):
        donor = Image.new('RGB', (40, 110), (160, 150, 110))
        draw = ImageDraw.Draw(donor)
        for y in range(0, 110, 5):
            draw.line((0, y, 39, y), fill=(125, 110, 70))
        field = water.hatch_field((256, 256), donor, 1.17, 118119)
        np.testing.assert_array_equal(field, water.hatch_field((256, 256), donor, 1.17, 118119))
        vertical = np.abs(np.diff(field, axis=0)).mean()
        horizontal = np.abs(np.diff(field, axis=1)).mean()
        self.assertGreater(vertical, horizontal * 3)
        self.assertLess(np.abs(field.mean(axis=(0, 1))).max(), 1)

    def test_zone_projection_retains_a_disconnected_offshore_island(self):
        core = Image.new('L', (100, 100))
        draw = ImageDraw.Draw(core)
        draw.rectangle((40, 40, 80, 80), fill=255)
        draw.rectangle((10, 10, 14, 14), fill=255)
        projected = water.project_land(core, [.2, .7, .3, .8], (400, 400))
        self.assertEqual(255, projected.getpixel((104, 144)))
        self.assertEqual(255, projected.getpixel((200, 240)))
        self.assertEqual(0, projected.getpixel((40, 144)))

    def test_sparse_tiles_preserve_water_alpha_across_grid_boundaries(self):
        painting = Image.new('RGB', (900, 700), (171, 151, 104))
        alpha = Image.new('L', painting.size)
        draw = ImageDraw.Draw(alpha)
        draw.line((450, 40, 650, 650), fill=255, width=16)
        draw.ellipse((490, 490, 535, 535), fill=255)
        assembled = Image.new('RGBA', painting.size)
        for texture, rect, uv in water.sparse_tiles(painting, alpha):
            self.assertLessEqual(max(texture.size), 512)
            crop = texture.crop((0, 0, round(uv[1] * texture.width), round(uv[3] * texture.height)))
            assembled.alpha_composite(crop, (round(rect[0] * painting.width), round(rect[1] * painting.height)))
        np.testing.assert_array_equal(np.asarray(alpha), np.asarray(assembled.getchannel('A')))

    def test_shipped_water_tiles_match_receipt_and_preserve_native_outer_contour(self):
        receipt = json.loads((ROOT / 'docs/research/map-water-hatching-2026-10-25.json').read_text())
        self.assertEqual({'118'}, set(receipt['art']))
        alpha = Image.new('L', (3840, 2560))
        for record in receipt['art']['118']:
            path = ROOT / f"UI/Maps/Media/WaterHatching/{record['file']}.blp"
            self.assertEqual(record['sha256'], hashlib.sha256(path.read_bytes()).hexdigest())
            texture = read_texture(path)
            self.assertEqual(tuple(record['texture_size']), texture.size)
            self.assertLessEqual(max(texture.size), 512)
            crop = texture.getchannel('A').crop((0, 0, round(record['uv'][1] * texture.width),
                                                round(record['uv'][3] * texture.height)))
            alpha.paste(crop, (round(record['rect'][0] * 3840), round(record['rect'][1] * 2560)))
        for point in ((3230, 2410), (3090, 2450), (3370, 2220), (2000, 1500), (1900, 2300),
                      (500, 1740), (982, 712), (982, 760)):
            self.assertEqual(0, alpha.getpixel(point), point)
        # The two reported coast regions must receive visible hatching.
        for point in ((695, 1954), (1364, 1681)):
            self.assertGreater(alpha.getpixel(point), 200, point)


if __name__ == '__main__':
    unittest.main()
