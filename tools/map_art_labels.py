"""Keep native place labels whole at painting seams, without OCR at runtime.

Select complete native labels using reviewed painting coordinates. These regions
exclude masonry, coastline strokes and frame ornaments that resemble lettering.
Accepted labels get their own final painted pass, below
terrain, so another painting cannot erase half a name. Label assets contain alpha
only; neighbouring paintings supply land behind discarded duplicate lettering.
"""
import numpy as np
from scipy import ndimage
from PIL import Image, ImageDraw, ImageFilter


def label_masks(painting, ownership, include=(), exclude=(), size=1024):
    """Return adjusted ownership and a mask for complete retained label groups.

    A name crossing the territory boundary is either removed completely or drawn
    completely. Explicit annotations resolve duplicate names in two paintings.
    The soft fringe sits outside the text, never through its letter strokes.
    """
    width, height = painting.size
    pixels = np.asarray(painting.convert('RGB'), dtype=np.int16)
    background = ndimage.median_filter(pixels, size=(7, 7, 1))
    strokes = np.max(np.abs(pixels - background), axis=2) > 24
    # Include each letter's dark outline, not the rectangular paper behind it.
    strokes = ndimage.binary_dilation(strokes, iterations=1)
    stroke_alpha = Image.fromarray(np.uint8(strokes) * 255)
    labels = Image.new('L', painting.size)
    removed = Image.new('L', painting.size)
    keep_draw, remove_draw = ImageDraw.Draw(labels), ImageDraw.Draw(removed)
    explicit = [(round(l * width), round(t * height), round(r * width), round(b * height))
                for l, t, r, b in include]
    blocked = [(round(l * width), round(t * height), round(r * width), round(b * height))
               for l, t, r, b in exclude]
    retained = explicit
    for l, t, r, b in retained:
        # The extra pixels are the feather, with the text itself kept opaque.
        keep_draw.rectangle((l - 4, t - 4, r + 4, b + 4), fill=255)
    for l, t, r, b in blocked:
        box = (l - 3, t - 3, r + 3, b + 3)
        remove_draw.rectangle(box, fill=255)
    # Removing glyphs lets the neighbour supply its own paper/land at that point.
    # Removing the entire rectangle would create a new visible rectangular patch.
    removed = Image.fromarray(np.minimum(np.asarray(removed), np.asarray(stroke_alpha)))
    cut = removed.filter(ImageFilter.MaxFilter(3)).resize(ownership.size, Image.Resampling.BOX)
    adjusted = Image.fromarray(np.minimum(np.asarray(ownership), 255 - np.asarray(cut)))
    labels = Image.fromarray(np.minimum(np.asarray(labels), np.asarray(stroke_alpha)))
    labels = labels.filter(ImageFilter.GaussianBlur(.4)).resize((size, size), Image.Resampling.BILINEAR)
    return adjusted, labels, retained


