"""Derive painted-zone coverage from native art, then arbitrate shared borders.

Exploration alpha includes copies of neighbouring parchment and decorations.
The pixels changed by exploration identify the useful interior of a painting.
All distance comparisons use the same physical scale, not each zone's size.
"""
import numpy as np
from scipy import ndimage
from PIL import Image, ImageChops, ImageDraw


def polygon_mask(polygons, size=512):
    """Rasterize independently annotated interiors in native painting space."""
    image = Image.new('L', (size, size))
    draw = ImageDraw.Draw(image)
    for polygon in polygons:
        draw.polygon([(round(x * size), round(y * size)) for x, y in polygon], fill=255)
    return image


def revealed_core(base, revealed, size=512):
    difference = ImageChops.difference(base.convert('RGB'), revealed.convert('RGB'))
    r, g, b = difference.split()
    difference = ImageChops.lighter(ImageChops.lighter(r, g), b)
    pixels = np.asarray(difference.resize((size, size), Image.Resampling.BOX))
    changed = pixels > 15
    components, count = ndimage.label(changed)
    sizes = np.bincount(components.ravel())
    peaks = ndimage.maximum(pixels, components, index=np.arange(count + 1))
    small = (sizes <= 16) & (peaks >= 64)
    small[0] = False
    islands = small[components]
    # Remove compression speckles; join thin, interrupted ink before filling
    # enclosed lakes/plain areas. Never replace disconnected islands by a hull.
    changed = ndimage.median_filter(changed, size=5)
    changed = ndimage.binary_closing(changed, iterations=4)
    changed = ndimage.binary_fill_holes(changed) | islands
    return Image.fromarray(np.uint8(changed) * 255)


def signed_distance(core, width=1, height=1):
    inside = np.asarray(core) > 127
    sampling = (height / core.height, width / core.width)
    # Explicit empty handling: scipy's all-foreground result has no real edge.
    if not inside.any():
        return np.full(inside.shape, -np.inf)
    padded = np.pad(inside, 1)
    inner = ndimage.distance_transform_edt(padded, sampling=sampling)[1:-1, 1:-1]
    outer = ndimage.distance_transform_edt(~inside, sampling=sampling)
    return inner - outer


def sample_field(field, source_rect, target_rect, size):
    sl, sr, st, sb = source_rect
    tl, tr, tt, tb = target_rect
    y, x = np.mgrid[:size, :size]
    x = ((tl + (x + .5) / size * (tr - tl) - sl) / (sr - sl)) * field.shape[1] - .5
    y = ((tt + (y + .5) / size * (tb - tt) - st) / (sb - st)) * field.shape[0] - .5
    return ndimage.map_coordinates(field, (y, x), order=1, mode='constant', cval=-1e6)


def painting_frame(size, inset=.045, fade=.02):
    y, x = np.mgrid[:size, :size]
    edge = np.minimum.reduce((x, y, size - 1 - x, size - 1 - y))
    frame = np.clip((edge - size * inset) / (size * fade), 0, 1)
    corner = np.minimum(x + y, size * 2 - 2 - x - y)
    return frame * np.clip((corner - size * .27) / (size * .035), 0, 1)


def territory(core, rect, competitors, reach=80, seam=4, priority=None, exclusions=(), strict_frame=False,
              frame_inset=.045, frame_fade=.02, priority_frame=False):
    """Retain nearby coast/mountains; a neighbour's deeper interior wins.

    competitors contains (rect, signed-distance field) in the same map space.
    Only offline generation performs these calculations; runtime samples BLPs.
    """
    l, r, t, b = rect
    pixel = min((r - l) / core.width, (b - t) / core.height)
    own = signed_distance(core, r - l, b - t)
    other = np.full(own.shape, -1e6)
    for rival_rect, field in competitors:
        if rival_rect[1] <= l or rival_rect[0] >= r or rival_rect[3] <= t or rival_rect[2] >= b:
            continue
        other = np.maximum(other, sample_field(field, rival_rect, rect, core.width))
    # A very narrow shared band hides minor differences between the paintings.
    weight = np.clip((own - other) / (seam * pixel) + .5, 0, 1)
    protected_weight = None
    if priority is not None:
        protected = signed_distance(priority, r - l, b - t)
        protected_weight = np.clip(protected / (seam * pixel) + .5, 0, 1)
        weight = np.maximum(weight, protected_weight)
    for exclusion in exclusions:
        rival_rect, field = exclusion[:2]
        protected = sample_field(field, rival_rect, rect, core.width)
        covered = np.clip(protected / (seam * pixel) + .5, 0, 1)
        if len(exclusion) > 2:
            available = sample_field(exclusion[2], rival_rect, rect, core.width)
            covered *= np.clip(available, 0, 1)
        weight *= 1 - covered
    coast = np.clip((own + reach * pixel) / (24 * pixel), 0, 1)
    if protected_weight is not None:
        coast = np.maximum(coast, protected_weight)
    frame = painting_frame(core.width, frame_inset, frame_fade)
    # A reviewed complete landmark may cross the template guard. Only that
    # landmark's local ownership can reopen the guard, never the whole edge.
    if priority_frame and protected_weight is not None:
        frame = np.maximum(frame, protected_weight)
    # Real newly revealed land may reach the frame: preserve it, never the
    # unchanged template decoration. This also keeps offshore islands intact.
    safe = frame if strict_frame else np.maximum(frame, np.clip(own / (pixel * 2), 0, 1))
    result = weight * coast * safe
    return Image.fromarray(np.uint8(np.rint(result * 255)))


def ocean_field(sample, size=512):
    """Rebuild paper/hatching statistics with independent random spatial phase.

    Colour and frequency strength come from a native ocean sample; glyphs and
    symbols cannot repeat because their spatial arrangement is discarded.
    The result is periodic, so hardware repeat needs no seams or mirror lines.
    """
    pixels = np.asarray(sample.convert('RGB'), dtype=float)
    noise = np.random.default_rng(51703).normal(size=(size, size))
    phase = np.fft.fft2(noise)
    phase /= np.maximum(np.abs(phase), 1e-6)
    output = np.empty((size, size, 3))
    for c in range(3):
        plane = pixels[:, :, c]
        mean = plane.mean()
        power = np.fft.fftshift(np.abs(np.fft.fft2(plane - mean)))
        power = ndimage.zoom(power, (size / plane.shape[0], size / plane.shape[1]), order=1)
        field = np.fft.ifft2(np.fft.ifftshift(power) * phase).real
        field *= min(plane.std(), 20) / max(field.std(), 1e-6)
        output[:, :, c] = mean + field
    return Image.fromarray(np.uint8(np.clip(output, 0, 255)))
