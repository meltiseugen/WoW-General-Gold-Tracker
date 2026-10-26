"""Restore native cartography through masked continent-frame corners.

Only corner assets are generated. The original paintings, territory masks,
ocean background and previous local repairs are never rewritten.
Requires Pillow, NumPy and SciPy; native client inputs must already be cached.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

from map_mask_texture import read_texture, save_texture
from map_preview_data import ClientMaps
from map_texture_repair import repair_texture


def erasure_mask(size: tuple[int, int], frame: Image.Image, bounds: Image.Image, settings: dict):
    """Remove reviewed ornament pixels while retaining intact native artwork."""
    polygons = settings.get('ornament_polygons')
    if not polygons:
        return ImageChops.invert(ImageChops.multiply(frame, bounds))
    ornament = Image.new('L', size)
    draw = ImageDraw.Draw(ornament)
    for polygon in polygons:
        draw.polygon([tuple(point) for point in polygon], fill=255)
    expansion = settings.get('expand', 0)
    if expansion:
        ornament = ornament.filter(ImageFilter.MaxFilter(expansion * 2 + 1))
    ornament = ornament.filter(ImageFilter.GaussianBlur(settings.get('feather', 0)))
    # Restore the water at the burnt outer edge too. The reviewed contour guard
    # keeps its native ink even where it approaches that edge.
    border = ImageChops.invert(bounds).resize(size, Image.Resampling.BILINEAR)
    erased = ImageChops.lighter(ornament, border)
    protected = Image.new('L', size)
    draw = ImageDraw.Draw(protected)
    width = settings.get('preserve_width', 32)
    for path in settings.get('preserve_paths', []):
        points = [tuple(point) for point in path]
        draw.line(points, fill=255, width=width, joint='curve')
        for x, y in points:
            draw.ellipse((x - width / 2, y - width / 2, x + width / 2, y + width / 2), fill=255)
    return ImageChops.subtract(erased, protected)


def corner_alpha(size: tuple[int, int], corner: str) -> Image.Image:
    """Opaque across the cutout; fade only beneath the intact original art."""
    width, height = size
    y, x = np.mgrid[:height, :width]
    distance = (x + .5) / width + (y + .5) / height
    if corner == 'bottom-right':
        distance = 2 - distance
    elif corner != 'top-left':
        raise ValueError(f'Unknown map corner: {corner}')
    # FrameCutout removes the diagonal below 135/512. The overlap keeps the
    # fill opaque through its antialias fringe; the original art hides the fade.
    opacity = np.clip((.31 - distance) / .025, 0, 1)
    return Image.fromarray(np.uint8(np.rint(opacity * 255)))


def pack_corner(painting: Image.Image, alpha: Image.Image):
    bounds = alpha.getbbox()
    if bounds is None:
        raise ValueError('Empty map corner')
    patch = painting.crop(bounds).convert('RGBA')
    patch.putalpha(alpha.crop(bounds))
    side = 16
    while side < max(patch.size):
        side *= 2
    padded = Image.new('RGBA', (side, side))
    padded.paste(patch, (0, 0))
    l, t, r, b = bounds
    rect = [l / painting.width, t / painting.height, r / painting.width, b / painting.height]
    uv = [0, patch.width / side, 0, patch.height / side]
    return padded, rect, uv


def corner_tiles(painting: Image.Image, alpha: Image.Image, corner: str, limit=1024):
    """Keep native pixels while avoiding large transparent texture allocations."""
    l, t, r, b = alpha.getbbox()

    def spans(low, high):
        if corner == 'bottom-right':
            return [(max(low, end - limit), end) for end in range(high, low, -limit)]
        return [(start, min(high, start + limit)) for start in range(low, high, limit)]

    for top, bottom in spans(t, b):
        for left, right in spans(l, r):
            box = (left, top, right, bottom)
            tile_alpha = alpha.crop(box)
            if tile_alpha.getbbox() is None:
                continue
            texture, local, uv = pack_corner(painting.crop(box), tile_alpha)
            width, height = right - left, bottom - top
            rect = [(left + local[0] * width) / painting.width,
                    (top + local[1] * height) / painting.height,
                    (left + local[2] * width) / painting.width,
                    (top + local[3] * height) / painting.height]
            yield texture, rect, uv


def digest(path: Path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generate(directory: Path, output: Path, index: Path, receipt: Path, recipe_path: Path):
    recipe = json.loads(recipe_path.read_text())
    maps = ClientMaps(directory)
    media = output.parent
    frame_path, bounds_path = media / 'FrameCutout.blp', media / 'BoundsFade.blp'
    frame = read_texture(frame_path).getchannel('A')
    bounds = read_texture(bounds_path).getchannel('A')
    records, inputs = {}, {}
    previous = json.loads(receipt.read_text()) if receipt.exists() else {}
    output.mkdir(parents=True, exist_ok=True)
    for art_text, corners in recipe['art'].items():
        art = int(art_text)
        layer = maps.layers[maps.styles[art]]
        painting = Image.new('RGBA', (int(layer['LayerWidth']), int(layer['LayerHeight'])))
        for tile in maps.tiles[art]:
            fid = int(tile['FileDataID'])
            path = directory / 'textures' / f'{fid}.blp'
            inputs[str(fid)] = digest(path)
            painting.paste(read_texture(path), (int(tile['ColIndex']) * int(layer['TileWidth']),
                                               int(tile['RowIndex']) * int(layer['TileHeight'])))
        records[art_text] = []
        for corner, settings in corners.items():
            print(f'Art {art}: {corner}', flush=True)
            sample = settings['sample']
            erased = erasure_mask(painting.size, frame, bounds, settings)
            restored = repair_texture(painting, erased, sample)
            alpha = corner_alpha(painting.size, corner)
            probes = settings.get('preserve_probes', [])
            for point in probes:
                pixel = tuple(point)
                if erased.getpixel(pixel) != 0 or alpha.getpixel(pixel) != 255:
                    raise ValueError(f'Native contour probe {point} is not fully preserved')
                if restored.getpixel(pixel) != painting.getpixel(pixel)[:3]:
                    raise ValueError(f'Native contour probe {point} changed during repair')
            for part, (texture, rect, uv) in enumerate(corner_tiles(restored, alpha, corner)):
                kind = 'native-' if settings.get('ornament_polygons') else ''
                name = f'{art}-{corner}-{kind}{part}'
                path = output / f'{name}.blp'
                save_texture(texture, path)
                record = {'corner': corner, 'file': name, 'rect': rect, 'uv': uv,
                                          'sample': sample, 'sha256': digest(path),
                                          'restoration': 'ornament-only' if kind else 'frame-cutout',
                                          'texture_size': list(texture.size)}
                native_pixels = [
                    {'pixel': point, 'rgb': list(painting.getpixel(tuple(point))[:3])}
                    for point in probes
                    if rect[0] <= point[0] / painting.width < rect[2]
                    and rect[1] <= point[1] / painting.height < rect[3]
                ]
                if native_pixels:
                    record['preserved_native_pixels'] = native_pixels
                records[art_text].append(record)
    current = {record['file'] for corners in records.values() for record in corners}
    for corners in previous.get('art', {}).values():
        for old in corners:
            path = output / (old['file'] + '.blp')
            if old['file'] not in current and path.exists() and digest(path) == old['sha256']:
                path.unlink()
    index.write_text('-- Generated by tools/generate_map_corner_fills.py; original native-ocean corner continuation.\n'
                     'local _, NS = ...\nNS.GoldTracker.MapCornerFills = {\n' +
                     ''.join(f'    [{art}] = {{\n' + ''.join(
                         '        { file = "' + record['file'] + '", rect = { ' + ', '.join(map(str, record['rect'])) +
                         ' }, uv = { ' + ', '.join(map(str, record['uv'])) + ' } },\n'
                         for record in corners) + '    },\n' for art, corners in records.items()) + '}\n', encoding='utf-8')
    receipt.write_text(json.dumps({
        'build': recipe['build'], 'scope': 'Only the masked top-left and bottom-right corners of standalone continent art.',
        'art': records, 'recipe_sha256': digest(recipe_path),
        'generator_sha256': digest(Path(__file__)),
        'repair_module_sha256': digest(Path(__file__).with_name('map_texture_repair.py')),
        'index_sha256': digest(index),
        'frame_sha256': digest(frame_path), 'bounds_sha256': digest(bounds_path),
        'native_texture_sha256': inputs,
        'copyright': 'Map art is © Blizzard Entertainment',
        'limitations': ['Generated native-ocean context is confined to the two corner supports.',
                        'Native WoW rendering remains to be verified in game.'],
    }, indent=2) + '\n', encoding='utf-8')
    print(f'Generated {sum(map(len, records.values()))} map corner fills', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path('.local/interactive-map-research'))
    parser.add_argument('--output', type=Path, default=Path('UI/Maps/Media/CornerFills'))
    parser.add_argument('--index', type=Path, default=Path('UI/Maps/CornerFillIndex.lua'))
    parser.add_argument('--receipt', type=Path, default=Path('docs/research/map-corners-2026-10-25.json'))
    parser.add_argument('--recipe', type=Path, default=Path('tools/map_corner_fills.json'))
    args = parser.parse_args()
    generate(args.input, args.output, args.index, args.receipt, args.recipe)
