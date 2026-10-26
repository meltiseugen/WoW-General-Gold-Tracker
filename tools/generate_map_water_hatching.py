"""Extend native fine water hatching through reviewed coastal water bands.

All image analysis happens offline. The game draws sparse, mipmapped patches
over painted water and under terrain. Ocean outside X and coast/contour ink remain
untouched. Requires Pillow, NumPy and SciPy and cached build-pinned client art.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw
from scipy import ndimage

from generate_map_corner_fills import pack_corner
from map_mask_texture import read_texture, save_texture
from map_preview_data import ClientMaps
from map_art_ownership import polygon_mask as normalized_polygons, revealed_core


def polygon_mask(size, points, reference):
    image = Image.new('L', size)
    ImageDraw.Draw(image).polygon([
        (round(x * size[0] / reference[0]), round(y * size[1] / reference[1]))
        for x, y in points
    ], fill=255)
    return np.asarray(image) > 0


def water_band(painting, settings, revealed_land=None):
    """Constrain replacement to Y..X, with native islands and ink protected."""
    reference = settings['reference_size']
    outer = polygon_mask(painting.size, settings['outer'], reference)
    land = polygon_mask(painting.size, settings['land'], reference)
    for points in settings.get('islands', []):
        land |= polygon_mask(painting.size, points, reference)
    rgb = np.asarray(painting.convert('RGB'), dtype=np.int16)
    r, g, b = rgb.transpose(2, 0, 1)
    # Reviewed native brown island fill and dark contour ink. Connected areas
    # distinguish landmarks from individual flecks in the old granular water.
    brown = ((r - g > 22) & (g - b > 25) & (b < 100)) | (
        (r + g < 240) & (r - g > 8) & (g - b > 15))
    labels, _ = ndimage.label(brown)
    counts = np.bincount(labels.ravel())
    ink = brown & (counts[labels] >= 20)
    if revealed_land is None:
        protected = land | ink
    else:
        # Detailed coastlines do not exactly follow the coarse continent land.
        # Protect the visible zone shoreline Y, not an obsolete parent coast.
        # Native ink protection is confined to the outer contour X in this pass.
        near_outer = ndimage.distance_transform_edt(outer) < 48
        protected = revealed_land | (ink & near_outer)
    distance = np.minimum(ndimage.distance_transform_edt(outer),
                          ndimage.distance_transform_edt(~protected))
    alpha = np.clip((distance - 5) / settings.get('feather', 8), 0, 1)
    alpha[~outer | protected] = 0
    return Image.fromarray(np.uint8(np.rint(alpha * 255)))


def hatch_field(size, donor, scale, seed):
    """Overlap native fine ink at geographic pixel scale, without colour blocks.

    Remove the donor's paper colour before assembling patches. Shared vertical
    phase within each row preserves short horizontal marks; overlapping rows
    and shuffled horizontal phases prevent a visibly repeated source rectangle.
    """
    sample = np.asarray(donor.convert('RGB'), dtype=np.float32)
    sample -= ndimage.gaussian_filter(sample, (3, 3, 0))
    pw, ph = max(4, round(donor.width * scale)), max(4, round(donor.height * scale))
    sample = ndimage.zoom(sample, (ph / donor.height, pw / donor.width, 1), order=1)
    weight = np.maximum(.001, np.outer(np.hanning(ph), np.hanning(pw)))[:, :, None]
    width, height = size
    field = np.zeros((height + ph, width + pw, 3), dtype=np.float32)
    weights = np.zeros((height + ph, width + pw, 1), dtype=np.float32)
    random = np.random.default_rng(seed)
    for y in range(0, height, ph // 2):
        phase = int(random.integers(0, ph))
        for x in range(0, width, pw // 2):
            part = np.roll(sample, (phase, int(random.integers(0, pw))), (0, 1))
            if random.integers(0, 2):
                part = part[:, ::-1]
            field[y:y + ph, x:x + pw] += part * weight
            weights[y:y + ph, x:x + pw] += weight
    return field[:height, :width] / weights[:height, :width]


def water_texture(painting, donor, scale, seed, safe_water=None):
    # Preserve the local water colour; replace granular detail with fine native
    # hatch ink, rather than laying one coloured donor rectangle over the sea.
    pixels = np.asarray(painting.convert('RGB'), dtype=np.float32)
    if safe_water is not None:
        # Fine coasts may lie inside the parent's old land outline. Continue
        # nearby native water colour there instead of carrying obsolete land
        # symbols or coarse island colours into the new water texture.
        yy, xx = ndimage.distance_transform_edt(~safe_water, return_distances=False, return_indices=True)
        pixels = pixels[yy, xx]
    base = ndimage.gaussian_filter(pixels, (10, 10, 0))
    ink = hatch_field(painting.size, donor, scale, seed)
    return Image.fromarray(np.uint8(np.clip(np.rint(base + ink * 1.25), 0, 255)))


def project_land(core, rect, size):
    """Put a zone's true revealed interior into continent-pixel coordinates."""
    left, right, top, bottom = rect
    sx, sy = core.width / ((right - left) * size[0]), core.height / ((bottom - top) * size[1])
    return core.transform(size, Image.Transform.AFFINE,
                          (sx, 0, -left * size[0] * sx, 0, sy, -top * size[1] * sy),
                          Image.Resampling.BILINEAR, fillcolor=0)


def sparse_tiles(painting, alpha, limit=512):
    """Crop each visible cell before padding; retain native resolution and alpha."""
    width, height = painting.size
    for top in range(0, height, limit):
        for left in range(0, width, limit):
            box = left, top, min(width, left + limit), min(height, top + limit)
            piece = alpha.crop(box)
            if piece.getbbox() is None:
                continue
            image, local, uv = pack_corner(painting.crop(box), piece)
            w, h = box[2] - left, box[3] - top
            rect = [(left + local[0] * w) / width, (top + local[1] * h) / height,
                    (left + local[2] * w) / width, (top + local[3] * h) / height]
            yield image, rect, uv


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generate(directory, output, index, receipt, recipe_path):
    recipe = json.loads(recipe_path.read_text())
    previous = json.loads(receipt.read_text()) if receipt.exists() else {}
    maps = ClientMaps(directory)
    inputs, paintings = {}, {}

    def native(art):
        if art not in paintings:
            layer = maps.layers[maps.styles[art]]
            image = Image.new('RGB', (int(layer['LayerWidth']), int(layer['LayerHeight'])))
            for tile in maps.tiles[art]:
                fid = int(tile['FileDataID'])
                path = directory / 'textures' / f'{fid}.blp'
                inputs[str(fid)] = digest(path)
                image.paste(read_texture(path), (int(tile['ColIndex']) * int(layer['TileWidth']),
                                                 int(tile['RowIndex']) * int(layer['TileHeight'])))
            paintings[art] = image
        return paintings[art]

    output.mkdir(parents=True, exist_ok=True)
    records = {}
    bounds_path = output.parent / 'BoundsFade.blp'
    bounds = read_texture(bounds_path).getchannel('A')
    annotations_path = Path(__file__).with_name('map_art_adjustments.json')
    annotations = json.loads(annotations_path.read_text())['art']
    for art_text, settings in recipe['art'].items():
        art, donor_art = int(art_text), settings['sample_art']
        source, donor = native(art), native(donor_art).crop(tuple(settings['sample']))
        # Derive scale from client geography, not from the current zoom level.
        root = next(mid for mid, aid in maps.arts.items() if aid == art)
        child = next(mid for mid, aid in maps.arts.items() if aid == donor_art)
        rect = maps.rect(child, root)
        scale = (rect[1] - rect[0]) * source.width / native(donor_art).width
        safe_water = np.asarray(water_band(source, settings)) == 255
        land = Image.new('L', source.size)
        for map_id, node in maps.fixture(root).items():
            if node['mapType'] != 3 or node['parentMapID'] != root:
                continue
            zone_art = node['artID']
            base = native(zone_art)
            revealed = base.convert('RGBA')
            layer = maps.layers[maps.styles[zone_art]]
            tw, th = int(layer['TileWidth']), int(layer['TileHeight'])
            for overlay in maps.overlays[zone_art]:
                ow, oh = int(overlay['TextureWidth']), int(overlay['TextureHeight'])
                ox, oy = int(overlay['OffsetX']), int(overlay['OffsetY'])
                for tile in maps.parts[overlay['ID']]:
                    col, row, fid = (int(tile[key]) for key in ('ColIndex', 'RowIndex', 'FileDataID'))
                    if fid <= 0:
                        continue
                    path = directory / 'textures' / f'{fid}.blp'
                    inputs[str(fid)] = digest(path)
                    image = read_texture(path).crop((0, 0, min(tw, ow - col * tw), min(th, oh - row * th)))
                    revealed.alpha_composite(image, (ox + col * tw, oy + row * th))
            outline = annotations.get(str(zone_art), {}).get('core')
            core = normalized_polygons(outline) if outline else revealed_core(base, revealed)
            # Some already-visible coastal headlands never change with fog.
            # Their reviewed shore contour must survive along with revealed land.
            shore = settings.get('shore_protection', {}).get(str(zone_art))
            if shore:
                core = ImageChops.lighter(core, normalized_polygons(shore))
            land = ImageChops.lighter(land, project_land(core, node['rect'], source.size))
        land = np.asarray(land) >= 8
        # Fill inland gaps, while retaining every disconnected offshore island.
        interior = polygon_mask(source.size, settings['land'], settings['reference_size'])
        land |= ndimage.distance_transform_edt(interior) >= 120
        land = ndimage.binary_fill_holes(ndimage.binary_closing(land, iterations=6))
        alpha = ImageChops.multiply(water_band(source, settings, land),
                                    bounds.resize(source.size, Image.Resampling.BILINEAR))
        restored = water_texture(source, donor, scale, art * 1000 + donor_art, safe_water)
        records[art_text] = []
        for part, (image, rect, uv) in enumerate(sparse_tiles(restored, alpha)):
            name = f'{art}-fine-water-{part}'
            path = output / (name + '.blp')
            save_texture(image, path)
            records[art_text].append({'file': name, 'rect': rect, 'uv': uv,
                                      'texture_size': list(image.size), 'sha256': digest(path)})
        print(f'Art {art}: {len(records[art_text])} sparse fine-water patches, scale {scale:.6f}', flush=True)
    current = {r['file'] for patches in records.values() for r in patches}
    for patches in previous.get('art', {}).values():
        for old in patches:
            path = output / (old['file'] + '.blp')
            if old['file'] not in current and path.exists() and digest(path) == old['sha256']:
                path.unlink()
    index.write_text('-- Generated by tools/generate_map_water_hatching.py; native coastal water hatch ink.\n'
                     'local _, NS = ...\nNS.GoldTracker.MapWaterHatching = {\n' + ''.join(
                         f'    [{art}] = {{\n' + ''.join(
                             '        { file = "' + record['file'] + '", rect = { ' +
                             ', '.join(map(str, record['rect'])) + ' }, uv = { ' +
                             ', '.join(map(str, record['uv'])) + ' } },\n' for record in patches)
                         + '    },\n' for art, patches in records.items()) + '}\n', encoding='utf-8')
    receipt.write_text(json.dumps({
        'build': recipe['build'], 'scope': 'Northrend coastal water between reviewed Y and X only.',
        'algorithm': 'native-fine-hatch-overlap-v1', 'art': records,
        'recipe_sha256': digest(recipe_path), 'generator_sha256': digest(Path(__file__)),
        'land_annotations_sha256': digest(annotations_path),
        'bounds_sha256': digest(bounds_path), 'index_sha256': digest(index),
        'native_texture_sha256': inputs, 'copyright': 'Map art is \u00a9 Blizzard Entertainment',
        'native_wow_validation': 'Pending; offline previews are not in-game verification.'
    }, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path('.local/interactive-map-research'))
    parser.add_argument('--output', type=Path, default=Path('UI/Maps/Media/WaterHatching'))
    parser.add_argument('--index', type=Path, default=Path('UI/Maps/WaterHatchingIndex.lua'))
    parser.add_argument('--receipt', type=Path, default=Path('docs/research/map-water-hatching-2026-10-25.json'))
    parser.add_argument('--recipe', type=Path, default=Path('tools/map_water_hatching.json'))
    args = parser.parse_args()
    generate(args.input, args.output, args.index, args.receipt, args.recipe)
