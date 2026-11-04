"""Fit short native road strips to reviewed joins between painted zones.

Both paths use fractions of the same painting. Only a narrow, feathered corridor
is exported; labels, terrain and map projection keep their original placement.
"""
import numpy as np
from scipy import ndimage
from PIL import Image


def _path(points, dimensions):
    pixels = np.asarray(points, dtype=float) * dimensions
    if pixels.ndim != 2 or pixels.shape[0] < 2 or pixels.shape[1] != 2:
        raise ValueError('A road path needs at least two coordinate pairs')
    steps = np.diff(pixels, axis=0)
    lengths = np.linalg.norm(steps, axis=1)
    if not np.isfinite(pixels).all() or np.any(lengths <= 0):
        raise ValueError('Road path segments must have finite, nonzero length')
    return pixels, steps, lengths, np.r_[0, lengths.cumsum()]


def road_patch(painting, source_path, target_path, width=9, feather=3):
    """Bend native double-line ink without redrawing or stretching its width.

    Arc length maps the donor along the join; signed perpendicular distance
    retains the original road's transverse scale. Both ends and sides fade.
    The generator performs this once; runtime draws one pooled texture quad.
    """
    if not 0 < feather < width:
        raise ValueError('Road feather must be positive and narrower than its corridor')
    dimensions = np.array(painting.size)
    source, _, _, source_distance = _path(source_path, dimensions)
    target, steps, lengths, distance = _path(target_path, dimensions)
    low = np.maximum(np.floor(target.min(axis=0) - width - 1).astype(int), 0)
    high = np.minimum(np.ceil(target.max(axis=0) + width + 2).astype(int), dimensions)
    if np.any(high <= low):
        raise ValueError('Road join is outside its painting')
    yy, xx = np.mgrid[low[1]:high[1], low[0]:high[0]]
    pixels = np.stack((xx, yy), axis=-1)
    nearest = np.full(xx.shape, np.inf)
    progress = np.zeros(xx.shape)
    across = np.zeros(xx.shape)
    for start, step, length, offset in zip(target[:-1], steps, lengths, distance[:-1]):
        fraction = np.clip(((pixels - start) * step).sum(axis=-1) / length**2, 0, 1)
        delta = pixels - start - fraction[..., None] * step
        error = (delta**2).sum(axis=-1)
        use = error < nearest
        nearest[use] = error[use]
        progress[use] = (offset + fraction[use] * length) / distance[-1]
        across[use] = (delta[..., 0] * -step[1] + delta[..., 1] * step[0])[use] / length
    along = progress * source_distance[-1]
    # Interpolate tangents at vertices too, preventing a diagonal stripe where
    # a piecewise path changes direction.
    tangent = np.gradient(source, source_distance, axis=0)
    dx = np.interp(along, source_distance, tangent[:, 0])
    dy = np.interp(along, source_distance, tangent[:, 1])
    norm = np.maximum(np.hypot(dx, dy), 1e-8)
    sx = np.interp(along, source_distance, source[:, 0]) - dy / norm * across
    sy = np.interp(along, source_distance, source[:, 1]) + dx / norm * across
    native = np.asarray(painting.convert('RGB'), dtype=float)
    rgb = np.stack([ndimage.map_coordinates(native[:, :, c], (sy, sx), order=1, mode='nearest')
                    for c in range(3)], axis=-1)
    side = np.clip((width - np.sqrt(nearest)) / feather, 0, 1)
    ends = np.clip(np.minimum(progress, 1 - progress) * distance[-1] / (feather * 2), 0, 1)
    alpha = side * side * (3 - 2 * side) * ends * ends * (3 - 2 * ends)
    patch = Image.fromarray(np.uint8(np.clip(np.dstack((rgb, alpha * 255)), 0, 255)))
    size = 16
    while size < max(patch.size):
        size *= 2
    padded = Image.new('RGBA', (size, size))
    padded.paste(patch)
    rect = [low[0]/dimensions[0], low[1]/dimensions[1], high[0]/dimensions[0], high[1]/dimensions[1]]
    uv = [0, patch.width/size, 0, patch.height/size]
    return padded, rect, uv
