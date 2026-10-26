import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
try:
    from PIL import Image, ImageDraw
    import numpy as np
    from scipy import ndimage
except ImportError:
    Image = None
else:
    sys.path.insert(0, str(ROOT / "tools"))
    try:
        spec = importlib.util.spec_from_file_location("map_art_masks", ROOT / "tools/generate_map_art_masks.py")
        masks = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(masks)
    finally:
        sys.path.pop(0)


@unittest.skipIf(Image is None, "Map mask generation checks require Pillow, NumPy and SciPy")
class MapArtMaskTests(unittest.TestCase):
    def test_preserves_isolated_islands_and_fills_inland_holes_without_retaining_frame(self):
        alpha = Image.new("L", (64, 64))
        draw = ImageDraw.Draw(alpha)
        draw.rectangle((20, 15, 40, 45), fill=255)
        draw.rectangle((25, 20, 30, 25), fill=0)
        alpha.putpixel((52, 12), 255)
        solid = masks.silhouette(alpha)
        result = masks.soften(solid, 2)
        self.assertEqual(255, result.getpixel((52, 12)))
        self.assertEqual(255, result.getpixel((27, 22)))
        self.assertEqual(0, result.getpixel((0, 0)))
        self.assertEqual(0, result.getpixel((60, 60)))

    def test_inset_projection_does_not_stretch_a_zone_across_the_continent(self):
        image = Image.new("L", (masks.SIZE, masks.SIZE), 255)
        result = masks.project(image, (.25, .5, .5, .75))
        self.assertEqual((128, 256, 256, 384), result.getbbox())
        self.assertEqual(0, result.getpixel((10, 10)))
        self.assertEqual(255, result.getpixel((180, 300)))

    def test_city_frame_cutout_preserves_title_and_opposite_corner_land(self):
        image=masks.frame_mask()
        self.assertEqual(0,image.getpixel((20,20)))
        self.assertEqual(0,image.getpixel((490,490)))
        self.assertEqual(255,image.getpixel((450,25)))
        self.assertEqual(255,image.getpixel((25,450)))

    def test_shipped_masks_match_the_receipt_and_cover_all_broken_isles_art(self):
        receipt = json.loads((ROOT / "docs/research/map-art-masks-2026-10-24.json").read_text())
        for art in (642, 653, 657, 664, 674, 704):
            self.assertIn(str(art), receipt["masks"])
        for art, record in receipt["masks"].items():
            path = ROOT / f"UI/Maps/Media/ArtMasks/{art}.blp"
            self.assertEqual(record["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())
            with Image.open(path) as image:
                self.assertEqual((512, 512), image.size)
                self.assertEqual("RGBA", image.mode)
        for art, expected in receipt["detail_backdrops"]["sha256"].items():
            path = ROOT / f"UI/Maps/Media/DetailBackdrop/{art}.blp"
            self.assertEqual(expected, hashlib.sha256(path.read_bytes()).hexdigest())
        for art, record in receipt.get("labels", {}).items():
            path = ROOT / f"UI/Maps/Media/ArtLabels/{art}.blp"
            self.assertEqual(record["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())
        for art, record in receipt.get("native_backgrounds", {}).items():
            for repair in record.get("repairs", []):
                path = ROOT / f"UI/Maps/Media/NativeBackgrounds/{repair['file']}.blp"
                self.assertEqual(repair["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())
        for art, repairs in receipt.get('caption_repairs', {}).items():
            for repair in repairs:
                path = ROOT / f"UI/Maps/Media/CaptionRepairs/{repair['file']}.blp"
                self.assertEqual(repair['sha256'],hashlib.sha256(path.read_bytes()).hexdigest())

    def test_local_art_restoration_changes_only_the_reviewed_stencil(self):
        from map_art_backgrounds import heal_patch
        rng = np.random.default_rng(7)
        pixels = rng.integers(110,145,(128,128,3),dtype=np.uint8)
        painting = Image.fromarray(pixels)
        ImageDraw.Draw(painting).line((75,45,75,85),fill=(0,0,0),width=3)
        patch,rect,uv = heal_patch(painting,paths=[[(75/128,45/128),(75/128,85/128)]],
                                  width=10,sample=(0,0,32,32))
        l,t,r,b = [round(v*128) for v in rect]
        actual = patch.crop((0,0,round(uv[1]*patch.width),round(uv[3]*patch.height)))
        restored = painting.convert('RGBA');restored.alpha_composite(actual,(l,t))
        allowed = np.zeros((128,128),dtype=bool)
        allowed[t:b,l:r] = np.asarray(actual.getchannel('A')) > 0
        self.assertTrue(np.array_equal(np.asarray(restored)[:,:,:3][~allowed],np.asarray(painting)[~allowed]))
        self.assertLess(allowed.mean(),.12)
        self.assertGreater(np.asarray(restored)[50:80,75,:3].mean(),90)

    def test_northrend_retains_native_ocean_with_only_local_marked_repairs(self):
        from map_mask_texture import read_texture
        receipt=json.loads((ROOT/'docs/research/map-art-masks-2026-10-24.json').read_text())
        record=receipt['native_backgrounds']['118']
        self.assertNotIn('ocean_art',record)
        self.assertNotIn('land_sha256',record)
        changed=0
        for repair in record['repairs']:
            if 'paths' not in repair:continue
            texture=read_texture(ROOT/f"UI/Maps/Media/NativeBackgrounds/{repair['file']}.blp")
            changed+=np.count_nonzero(np.asarray(texture.getchannel('A')))
        self.assertLess(changed/(3840*2560),.08)

    def test_priority_cannot_remove_a_neighbour_where_the_owning_frame_is_invisible(self):
        from map_art_ownership import signed_distance, territory
        core = Image.new("L", (128, 128), 255)
        rect = (0, 1, 0, 1)
        invisible = np.zeros((128, 128))
        result = territory(core, rect, [], exclusions=[(rect, signed_distance(core), invisible)])
        self.assertEqual(255, result.getpixel((64, 64)))

    def test_cleanup_leaves_the_native_shallow_deep_water_contour_visible(self):
        from map_mask_texture import read_texture
        receipt = json.loads((ROOT / 'docs/research/map-art-masks-2026-10-24.json').read_text())
        # Reviewed points on the previously erased western, eastern and southern
        # depth contour, in the original Northrend painting's coordinates.
        points = [(.221769, .275796), (.237749, .829596), (.443016, .723512),
                  (.848702, .516131), (.616675, .859218), (.407780, .108938)]
        covered = [0] * len(points)
        for repair in receipt['native_backgrounds']['118']['repairs']:
            l, t, r, b = repair['target']
            texture = read_texture(ROOT / f"UI/Maps/Media/NativeBackgrounds/{repair['file']}.blp")
            alpha = texture.getchannel('A')
            uv = repair['uv']
            for index, (x, y) in enumerate(points):
                if l <= x <= r and t <= y <= b:
                    px = round((x - l) / (r - l) * uv[1] * texture.width)
                    py = round((y - t) / (b - t) * uv[3] * texture.height)
                    covered[index] = max(covered[index], alpha.crop((px - 3, py - 3, px + 4, py + 4)).getextrema()[1])
        self.assertEqual([0] * len(points), covered)

    def test_priority_coverage_reaches_a_landmark_outside_the_generic_coastal_halo(self):
        from map_art_ownership import polygon_mask, territory
        core = Image.new("L", (128, 128))
        ImageDraw.Draw(core).rectangle((15, 40, 35, 80), fill=255)
        landmark = polygon_mask([[(.6, .4), (.8, .4), (.8, .7), (.6, .7)]], 128)
        mask = territory(core, (0, 1, 0, 1), [], reach=10, priority=landmark, seam=8)
        self.assertEqual(255, mask.getpixel((90, 70)))

    def test_ridge_repair_uses_native_pixels_and_fades_before_its_padded_bounds(self):
        from map_art_backgrounds import ridge_patch
        native = Image.new("RGB", (200, 200), (170, 140, 100))
        patch, uv = ridge_patch(native, (.25, .25, .75, .75))
        self.assertEqual((128, 128), patch.size)
        self.assertEqual((170, 140, 100, 255), patch.getpixel((50, 50)))
        self.assertEqual(0, patch.getpixel((0, 50))[3])
        self.assertEqual(0, patch.getpixel((110, 110))[3])
        self.assertEqual([0, 100 / 128, 0, 100 / 128], uv)

    def test_draktharon_combines_zuldrak_ground_with_the_complete_grizzly_front_gate(self):
        from map_mask_texture import read_texture
        grizzly = read_texture(ROOT / "UI/Maps/Media/ArtMasks/121.blp").getchannel("A")
        zuldrak = read_texture(ROOT / "UI/Maps/Media/ArtMasks/126.blp").getchannel("A")
        # Preserve Zul'Drak's upper ground and fortification around the keep.
        for y in (.81, .83):
            self.assertGreater(zuldrak.getpixel((round(.29 * 512), round(y * 512))), 240)
        # The foreground includes the full tall gate from Grizzly Hills.
        for y in (.89, .91, .93, .95):
            root_x, root_y = .55 + .29 * .2651, .2737 + y * .2650
            point = (round((root_x - .5771) / .2787 * 512), round((root_y - .445) / .2787 * 512))
            self.assertGreater(grizzly.getpixel(point), 240)
            self.assertLess(zuldrak.getpixel((round(.29 * 512), round(y * 512))), 15)
        self.assertGreater(zuldrak.getpixel((round(.19 * 512), round(.91 * 512))), 240)
        receipt = json.loads((ROOT / 'docs/research/map-art-masks-2026-10-24.json').read_text())
        self.assertNotIn('126', receipt.get('caption_repairs', {}))

    def test_landmark_composite_never_exposes_the_continent_through_its_soft_join(self):
        blank = Image.new('L', (512, 512))
        front, back = masks.blend_landmark_masks(blank, Image.new('L', blank.size, 255),
            [[.3,.3],[.7,.3],[.7,.7],[.3,.7]], [.2,.8,.1,.9])
        projected = np.asarray(masks.project(front, [.2,.8,.1,.9]), dtype=float) / 255
        background = np.asarray(back, dtype=float) / 255
        coverage = background + (1 - background) * projected
        self.assertGreaterEqual(float(coverage.min()), 254 / 255)
        self.assertEqual(255, front.getpixel((256,256)))
        self.assertEqual(0, back.getpixel((256,256)))
        self.assertEqual(255, back.getpixel((30,30)))

    def test_reviewed_landmark_frame_override_is_local_to_its_outline(self):
        from map_art_ownership import polygon_mask, territory
        core = Image.new('L', (128, 128), 255)
        landmark = polygon_mask([[ (.3,.8),(.6,.8),(.6,.99),(.3,.99) ]], 128)
        mask = territory(core, (0,1,0,1), [], priority=landmark, priority_frame=True,
                         strict_frame=True, frame_fade=.07, seam=2)
        self.assertEqual(255, mask.getpixel((60,121)))
        self.assertEqual(0, mask.getpixel((124,124)))

    def test_texture_overlap_cut_follows_connected_low_error_native_strokes(self):
        from map_texture_repair import minimum_cut
        error = np.full((5,5),100.0)
        path = [1,2,3,2,2]
        error[np.arange(5),path] = 0
        np.testing.assert_array_equal(minimum_cut(error),path)

    def test_strict_painting_frame_cannot_be_revived_by_a_changed_ornament(self):
        from map_art_ownership import territory
        core = Image.new("L", (128, 128), 255)
        mask = territory(core, (0, 1, 0, 1), [], strict_frame=True)
        self.assertEqual(0, mask.getpixel((124, 124)))
        self.assertEqual(255, mask.getpixel((64, 64)))

    def test_protected_labels_never_redraw_the_castle_below_draktharon_keep(self):
        from map_mask_texture import read_texture
        labels = read_texture(ROOT / "UI/Maps/Media/ArtLabels/121.blp").getchannel("A")
        self.assertEqual(0, labels.crop((130, 235, 220, 280)).getextrema()[1])
        self.assertEqual(0, labels.crop((970, 970, 1024, 1024)).getextrema()[1])

    def test_reported_edge_labels_have_complete_explicit_label_regions(self):
        from map_mask_texture import read_texture
        for art, left, right in ((121, (235, 285, 265, 330), (290, 285, 325, 330)),
                                 (122, (215, 175, 245, 235), (280, 175, 315, 235)),
                                 (123, (48, 365, 70, 425), (108, 365, 128, 425))):
            labels = read_texture(ROOT / f"UI/Maps/Media/ArtLabels/{art}.blp").getchannel("A")
            self.assertGreater(labels.crop(left).getextrema()[1], 240)
            self.assertGreater(labels.crop(right).getextrema()[1], 240)

    def test_base_only_northrend_maps_have_visible_land_and_no_decorative_corners(self):
        from map_mask_texture import read_texture
        for art, point in ((128, (256, 256)), (175, (256, 110))):
            mask = read_texture(ROOT / f"UI/Maps/Media/ArtMasks/{art}.blp").getchannel("A")
            self.assertGreater(mask.getpixel(point), 240)
            self.assertEqual(0, mask.getpixel((0, 0)))
            self.assertEqual(0, mask.getpixel((511, 511)))

    def test_priority_blends_preserve_the_owning_painting_on_both_sides(self):
        from map_art_ownership import polygon_mask, signed_distance, territory
        core = Image.new("L", (128, 128), 255)
        protected = polygon_mask([[(.4, .3), (.7, .3), (.7, .7), (.4, .7)]], 128)
        rect = (0, 1, 0, 1)
        field = signed_distance(protected)
        owner = territory(core, rect, [(rect, signed_distance(core))], priority=protected, seam=18)
        other = territory(core, rect, [(rect, signed_distance(core))], exclusions=[(rect, field)], seam=18)
        self.assertEqual(255, owner.getpixel((70, 64)))
        self.assertEqual(0, other.getpixel((70, 64)))
        self.assertGreater(other.getpixel((48, 64)), 0)
        self.assertLess(other.getpixel((48, 64)), 128)

    def test_label_retention_keeps_the_complete_name_and_suppresses_duplicate_names_whole(self):
        from map_art_labels import label_masks
        painting = Image.new("RGB", (128, 128), (170, 140, 90))
        draw = ImageDraw.Draw(painting)
        draw.text((26, 26), "KEEP", fill=(240, 220, 160), stroke_fill=(50, 30, 15), stroke_width=1)
        draw.text((80, 80), "OLD", fill=(240, 220, 160), stroke_fill=(50, 30, 15), stroke_width=1)
        ownership = Image.new("L", (128, 128), 255)
        core = ownership.copy()
        owner, labels, _ = label_masks(painting, ownership,
            include=[(.2, .2, .5, .4)], exclude=[(.6, .6, .9, .8)], size=128)
        for box, keep in (((26, 26, 64, 51), True), ((80, 80, 115, 102), False)):
            l, t, r, b = box
            ink = [(x, y) for y in range(t, b) for x in range(l, r) if painting.getpixel((x, y))[0] > 225]
            self.assertGreater(len(ink), 5)
            for point in ink:
                if keep:
                    self.assertGreater(labels.getpixel(point), 240)
                else:
                    self.assertEqual(0, owner.getpixel(point))
                    self.assertEqual(0, labels.getpixel(point))
        self.assertEqual(0, labels.getpixel((62, 49)))  # No rectangular paper patch.

    def test_draktharon_keep_has_a_complete_canonical_label_above_the_zone_seam(self):
        from map_mask_texture import read_texture
        labels = read_texture(ROOT / "UI/Maps/Media/ArtLabels/121.blp").getchannel("A")
        for x in (139, 176, 224):
            self.assertGreater(labels.crop((x, 170, x + 3, 211)).getextrema()[1], 240)

    def test_stormheim_cannot_cover_highmountain_with_its_northwest_frame(self):
        # Native art 657: this strip crossed Highmountain in the reported view.
        # The interior and Shield's Rest must survive the same cutout.
        from map_mask_texture import read_texture
        mask = read_texture(ROOT / "UI/Maps/Media/ArtMasks/657.blp").getchannel("A")
        for point in ((150, 35), (150, 70), (150, 100)):
            self.assertEqual(0, mask.getpixel(point))
        for point in ((300, 250), (450, 45)):
            self.assertEqual(255, mask.getpixel(point))

    def test_compressed_mask_roundtrips_alpha_and_includes_all_mip_levels(self):
        import struct
        from io import BytesIO
        source = Image.new("L", (16, 16))
        ImageDraw.Draw(source).rectangle((4, 4, 11, 11), fill=255)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/"mask.blp"
            masks.save_mask(source, path)
            data = path.read_bytes()
        offsets = struct.unpack_from("<16I", data, 20)
        self.assertEqual(5, sum(bool(n) for n in offsets))
        self.assertEqual(b"BLP2", data[:4])
        with Image.open(BytesIO(data)) as image:
            self.assertEqual(source.tobytes(), image.getchannel("A").tobytes())

    def test_ocean_fill_is_sampled_away_from_land_and_tiles_without_edge_jumps(self):
        with tempfile.TemporaryDirectory() as directory:
            cache = Path(directory)
            source = Image.new("RGB", (256,256), (130,130,115))
            ImageDraw.Draw(source).rectangle((64,64,127,127),fill=(220,150,70))
            source.save(cache/'123.blp', format='PNG')
            land = Image.new('L',(512,512))
            ImageDraw.Draw(land).rectangle((128,128,255,255),fill=255)
            node = {'textures':[123], 'layer':{'layerWidth':256,'layerHeight':256,'tileWidth':256,'tileHeight':256}}
            paper, provenance = masks.sea_patch(node,land,cache)
        self.assertEqual(123,provenance['fileDataID'])
        self.assertNotEqual((64,64,128,128),provenance['rect'])
        for p in range(128):
            self.assertEqual(paper.getpixel((0,p)),paper.getpixel((127,p)))
            self.assertEqual(paper.getpixel((p,0)),paper.getpixel((p,127)))

    def test_ocean_grain_does_not_repeat_ink_or_decorative_symbols(self):
        from PIL import ImageStat
        patch=Image.new('RGB',(64,64),(145,140,113))
        ImageDraw.Draw(patch).ellipse((15,20,48,40),fill=(35,25,10))
        result=masks.paper_field(patch)
        self.assertLess(max(ImageStat.Stat(result).stddev),4)

    def test_revealed_core_excludes_unchanged_burnt_frame_and_neighbour_parchment(self):
        from map_art_ownership import revealed_core
        base=Image.new('RGB',(512,512),(170,140,80))
        ImageDraw.Draw(base).rectangle((0,0,511,24),fill=(40,25,10))
        revealed=base.copy()
        ImageDraw.Draw(revealed).ellipse((150,120,400,420),fill=(50,100,40))
        core=revealed_core(base,revealed)
        self.assertEqual(0,core.getpixel((250,12)))
        self.assertEqual(0,core.getpixel((80,200)))
        self.assertEqual(255,core.getpixel((280,250)))

    def test_revealed_core_keeps_a_small_disconnected_island(self):
        from map_art_ownership import revealed_core
        base=Image.new('RGB',(512,512),(180,160,100));revealed=base.copy()
        ImageDraw.Draw(revealed).ellipse((150,120,400,420),fill=(50,100,40))
        ImageDraw.Draw(revealed).rectangle((70,90,72,92),fill=(20,90,40))
        self.assertEqual(255,revealed_core(base,revealed).getpixel((71,91)))

    def test_neighbour_interior_wins_over_another_maps_border_band(self):
        from map_art_ownership import signed_distance,territory
        west=Image.new('L',(128,128));east=west.copy()
        ImageDraw.Draw(west).rectangle((10,20,55,110),fill=255)
        ImageDraw.Draw(east).rectangle((65,20,115,110),fill=255)
        rect=(0,1,0,1)
        mask=territory(west,rect,[(rect,signed_distance(east))])
        self.assertEqual(255,mask.getpixel((30,65)))
        self.assertEqual(0,mask.getpixel((90,65)))
        self.assertEqual(0,mask.getpixel((90,3)))

    def test_ownership_uses_geography_across_different_painting_sizes(self):
        from map_art_ownership import sample_field
        field=np.tile(np.linspace(0,1,128),(128,1))
        sampled=sample_field(field,(.2,.6,.1,.8),(.3,.5,.1,.8),128)
        self.assertAlmostEqual(.5,float(sampled[64,64]),places=2)
        self.assertLess(float(sampled[64,0]),.26)
        self.assertGreater(float(sampled[64,-1]),.74)

    def test_detail_ocean_preserves_colour_without_repeating_source_glyphs(self):
        from map_art_ownership import ocean_field
        source=Image.new('RGB',(64,64),(140,135,115))
        ImageDraw.Draw(source).rectangle((20,15,28,50),fill=(30,20,10))
        field=ocean_field(source)
        self.assertEqual((512,512),field.size)
        self.assertTrue(np.all(np.abs(np.asarray(field).mean(axis=(0,1))-np.asarray(source).mean(axis=(0,1)))<2))
        self.assertEqual(field.tobytes(),ocean_field(source).tobytes())

    def test_native_block_decoder_preserves_alpha_and_image_shape(self):
        from map_mask_texture import read_texture
        path=ROOT/'UI/Maps/Media/ArtMasks/657.blp'
        with Image.open(path) as expected:
            actual=read_texture(path)
            self.assertEqual(expected.size,actual.size)
            self.assertEqual(expected.getchannel('A').tobytes(),actual.getchannel('A').tobytes())


if __name__ == "__main__":
    unittest.main()
