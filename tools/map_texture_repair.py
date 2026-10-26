"""Repair a masked duplicate caption with context-matched native ground patches.

Independently authored image quilting: context selects source patches and
minimum-cost overlap cuts avoid square patch edges. See Efros and Freeman,
SIGGRAPH 2001: https://people.eecs.berkeley.edu/~efros/research/quilting.html
Only the offline generator uses this module.
"""
import numpy as np
from scipy import ndimage
from scipy import sparse
from scipy.sparse.linalg import cg
from PIL import Image


def minimum_cut(error):
    """One connected, minimum-cost top-to-bottom path through an overlap."""
    height, width = error.shape
    cost = error.astype(float).copy()
    parent = np.zeros((height, width), dtype=np.int16)
    columns = np.arange(width)
    for y in range(1, height):
        previous = np.pad(cost[y - 1], (1, 1), constant_values=np.inf)
        choices = np.stack((previous[:-2], previous[1:-1], previous[2:]))
        step = np.argmin(choices, axis=0)
        parent[y] = columns + step - 1
        cost[y] += choices[step, columns]
    path = np.empty(height, dtype=int)
    path[-1] = np.argmin(cost[-1])
    for y in range(height - 1, 0, -1):
        path[y - 1] = parent[y, path[y]]
    return path


def _overlap(old, candidate, known):
    size = known.shape[0]
    band = size // 4
    error = np.square(old.astype(float) - candidate).sum(axis=2)
    error[~known] = 0
    take = np.ones_like(known)
    y, x = np.mgrid[:size, :size]
    if known[:, :band].mean() > .35:
        take &= x >= minimum_cut(error[:, :band])[:, None]
    if known[:, -band:].mean() > .35:
        take &= x <= size - band + minimum_cut(error[:, -band:])[:, None]
    if known[:band].mean() > .35:
        take &= y >= minimum_cut(error[:band].T)[None, :]
    if known[-band:].mean() > .35:
        take &= y <= size - band + minimum_cut(error[-band:].T)[None, :]
    return take | ~known


def _join_patches(pixels, shifts, editable):
    """Remove patch colour steps while retaining native gradients inside them.

    A sparse Poisson solve integrates the native strokes, omitting artificial
    gradients at donor changes. Original pixels are the fixed boundary condition.
    Solve at the matching resolution so donor boundaries cannot leave a
    staircase of colour steps. Full native grain is retained later.
    """
    h, w = editable.shape
    small = pixels.astype(float)
    change = editable
    offsets = shifts
    ids = np.full(change.shape, -1, dtype=np.int32)
    ids[change] = np.arange(change.sum())
    if not change.any(): return pixels.astype(float)
    rows, cols, values = [], [], []
    rhs = np.zeros((change.sum(), 3))
    diagonal = np.zeros(change.sum())
    # Undirected edges contribute opposite native gradients to their endpoints.
    for axis in (0, 1):
        a = (slice(None, -1), slice(None)) if axis == 0 else (slice(None), slice(None, -1))
        b = (slice(1, None), slice(None)) if axis == 0 else (slice(None), slice(1, None))
        ia, ib = ids[a].ravel(), ids[b].ravel()
        va, vb = small[a].reshape(-1,3), small[b].reshape(-1,3)
        jump = np.any(offsets[a] != offsets[b], axis=2).ravel()
        gradient = va - vb
        gradient[jump] = 0
        for first, second, vsecond, g in ((ia,ib,vb,gradient),(ib,ia,va,-gradient)):
            use = first >= 0
            i, j = first[use], second[use]
            diagonal[i] += 1
            rhs[i] += g[use]
            fixed = j < 0
            rhs[i[fixed]] += vsecond[use][fixed]
            rows.append(i[~fixed]); cols.append(j[~fixed]); values.append(-np.ones((~fixed).sum()))
    # The small screen term anchors broad colour to the original patch fit and
    # stabilizes fully masked corners without reintroducing their sharp edges.
    screen = .002
    rhs += screen * small[change]
    diagonal += screen
    rows.append(np.arange(len(diagonal))); cols.append(rows[-1]); values.append(diagonal)
    matrix = sparse.coo_matrix((np.concatenate(values),(np.concatenate(rows),np.concatenate(cols))),
                              shape=(len(diagonal),len(diagonal))).tocsr()
    joined = small.copy()
    for channel in range(3):
        solution, status = cg(matrix, rhs[:,channel], x0=small[change,channel], rtol=1e-5, maxiter=350)
        if status < 0: raise RuntimeError('Native patch colour integration failed')
        joined[change,channel] = solution
    correction = joined - small
    return np.clip(pixels.astype(float) + correction,0,255)


def repair_texture(painting, erase, sample_box, source_exclusions=(), ignore=None):
    """Keep unmasked pixels; reconstruct the mask from original water patches.

    Matching runs at a bounded working resolution. An offset field then copies
    full-resolution native pixels, preserving grain and wave strokes. No resized
    replacement, random phase, mirrored tile or row stretching enters the result.
    """
    original = np.asarray(painting.convert('RGB'))
    height, width = original.shape[:2]
    scale = 2 if min(width, height) >= 512 and min(sample_box[2]-sample_box[0],sample_box[3]-sample_box[1]) >= 64 else 1
    w, h = width // scale, height // scale
    work = np.asarray(painting.convert('RGB').resize((w, h), Image.Resampling.BOX))
    opacity = np.asarray(erase.resize((w, h), Image.Resampling.BILINEAR))
    frozen = opacity == 0
    # Only the reviewed ground rectangle is a donor. Other unmasked
    # pixels may contain lettering or landmarks and are never safe.
    available = np.zeros_like(frozen)
    for l, t, r, b in source_exclusions:
        available[round(t * h):round(b * h), round(l * w):round(r * w)] = False
    l, t, r, b = (round(value / scale) for value in sample_box)
    available[t:b, l:r] = True
    frozen[t:b, l:r] = True
    target = ~frozen
    if ignore is not None:
        target &= np.asarray(ignore.resize((w, h), Image.Resampling.NEAREST)) < 255
    if not target.any():
        return painting.convert('RGB')

    size, step, features = 32, 16, 8
    half, cell = size // 2, size // features
    safe = ndimage.minimum_filter(available, size=size, mode='constant', cval=0)
    source = [(y, x) for y in range(half, h - half, 6)
              for x in range(half, w - half, 6) if safe[y, x]]
    if not source:
        raise ValueError('The reviewed native ocean sample cannot supply a clean patch')
    if len(source) > 6000:
        source = [source[i] for i in np.linspace(0, len(source) - 1, 6000, dtype=int)]
    descriptors = np.empty((len(source), features * features * 3), dtype=np.float32)
    for i, (y, x) in enumerate(source):
        patch = work[y - half:y + half, x - half:x + half]
        descriptors[i] = patch.reshape(features, cell, features, cell, 3).mean(axis=(1, 3)).ravel()
    squared = descriptors * descriptors

    pad = size
    output = np.pad(work, ((pad, pad), (pad, pad), (0, 0)), mode='edge').copy()
    known = np.pad(frozen, pad)
    protected = known.copy()
    offsets = np.zeros((*known.shape, 2), dtype=np.int32)
    biases = np.zeros((*known.shape, 3), dtype=np.float32)
    grid_h, grid_w = (h + step - 1) // step, (w + step - 1) // step
    grid = np.zeros((grid_h, grid_w), dtype=bool)
    for gy in range(grid_h):
        for gx in range(grid_w):
            grid[gy, gx] = target[gy * step:(gy + 1) * step, gx * step:(gx + 1) * step].any()
    distance = ndimage.distance_transform_edt(grid)
    positions = sorted(zip(*np.nonzero(grid)), key=lambda p: (distance[p], p[0], p[1]))
    for gy, gx in positions:
        cy, cx = min(gy * step + step // 2, h - 1), min(gx * step + step // 2, w - 1)
        top, left = cy + pad - half, cx + pad - half
        region = np.s_[top:top + size, left:left + size]
        central = known[cy + pad - step // 2:cy + pad + step // 2,
                        cx + pad - step // 2:cx + pad + step // 2]
        if central.all():
            continue
        old, context = output[region], known[region]
        counts = context.reshape(features, cell, features, cell).sum(axis=(1, 3))
        totals = (old * context[:, :, None]).reshape(features, cell, features, cell, 3).sum(axis=(1, 3))
        values = totals / np.maximum(counts[:, :, None], 1)
        weight = np.repeat(counts[:, :, None] / (cell * cell), 3, axis=2).ravel().astype(np.float32)
        if weight.sum():
            vector = values.ravel().astype(np.float32)
            scores = squared @ weight - 2 * (descriptors @ (weight * vector))
            shortlist = np.argpartition(scores, min(23, len(scores) - 1))[:24]
            # Coarse means shortlist patches; actual native strokes determine
            # the final fit. Means alone lose the phase of the wave hatching.
            best, chosen, bias = np.inf, 0, np.zeros(3)
            for i in shortlist:
                sy, sx = source[i]
                candidate = work[sy - half:sy + half, sx - half:sx + half].astype(float)
                delta = np.clip((old.astype(float) - candidate)[context].mean(axis=0), -12, 12)
                error = np.square((old.astype(float) - candidate - delta)[context]).mean()
                if error < best:
                    best, chosen, bias = error, int(i), delta
        else:
            chosen = (gy * 131 + gx * 193) % len(source)
            bias = np.zeros(3)
        sy, sx = source[chosen]
        candidate = np.clip(work[sy - half:sy + half, sx - half:sx + half].astype(float) + bias, 0, 255)
        take = _overlap(old, candidate, context) & ~protected[region]
        old[take] = candidate[take]
        offsets[region][take] = (sy - cy, sx - cx)
        biases[region][take] = bias
        known[region][take] = True

    shifts = offsets[pad:pad + h, pad:pad + w]
    biases = biases[pad:pad + h, pad:pad + w]
    joined = _join_patches(output[pad:pad+h,pad:pad+w], shifts, target)
    correction = joined - output[pad:pad+h,pad:pad+w].astype(float)
    native_opacity = np.asarray(erase.resize((width, height), Image.Resampling.BILINEAR))
    result = original.copy()
    columns = np.arange(width)
    work_columns = np.minimum(columns // scale, w - 1)
    for y in range(height):
        if not native_opacity[y].any(): continue
        shift = shifts[min(y // scale, h - 1), work_columns] * scale
        yy = np.clip(y + shift[:, 0], 0, height - 1)
        xx = np.clip(columns + shift[:, 1], 0, width - 1)
        alpha = native_opacity[y].astype(float)[:, None] / 255
        line = min(y // scale,h - 1)
        donor = np.clip(original[yy, xx].astype(float) + biases[line,work_columns] + correction[line,work_columns], 0, 255)
        result[y] = np.uint8(np.rint(original[y] * (1 - alpha) + donor * alpha))
    return Image.fromarray(result)
