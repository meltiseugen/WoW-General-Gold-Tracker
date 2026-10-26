"""Local native-art repairs for reported map landmarks and duplicate captions.

The original continent texture remains the background. Only reviewed defect
stencils receive local repair overlays.
"""
import numpy as np
from PIL import Image, ImageFilter
from map_texture_repair import repair_texture


def heal_patch(painting, paths=(), polygons=(), width=24, sample=(256,384,768,896)):
    """Heal only annotated coarse ink/debris; leave all other pixels untouched.

    Only the marked strokes are restored from their immediate context. No ocean
    texture is generated or repeated across the surrounding background.
    """
    from PIL import ImageDraw
    w,h=painting.size
    mask=Image.new('L',painting.size);draw=ImageDraw.Draw(mask)
    for path in paths:
        points=[(round(x*w),round(y*h)) for x,y in path]
        draw.line(points,fill=255,width=width,joint='curve')
        for x,y in points:draw.ellipse((x-width/2,y-width/2,x+width/2,y+width/2),fill=255)
    for polygon in polygons:draw.polygon([(round(x*w),round(y*h)) for x,y in polygon],fill=255)
    alpha=mask.filter(ImageFilter.GaussianBlur(2))
    l,t,r,b=alpha.getbbox();l,t,r,b=max(0,l-16),max(0,t-16),min(w,r+16),min(h,b+16)
    restored=repair_texture(painting,alpha,sample)
    pixels=np.asarray(restored.crop((l,t,r,b)))
    patch=Image.fromarray(np.uint8(np.clip(pixels,0,255))).convert('RGBA')
    patch.putalpha(alpha.crop((l,t,r,b)))
    size=16
    while size<max(patch.size):size*=2
    padded=Image.new('RGBA',(size,size));padded.paste(patch,(0,0))
    return padded,[l/w,t/h,r/w,b/h],[0,patch.width/size,0,patch.height/size]


def caption_patch(painting, target, sample):
    """Replace a duplicate caption with nearby native ground, below label ink."""
    w,h = painting.size
    box = tuple(round(value*size) for value,size in zip(target,(w,h,w,h)))
    donor = tuple(round(value*size) for value,size in zip(sample,(w,h,w,h)))
    erase = Image.new('L',painting.size)
    from PIL import ImageDraw
    ImageDraw.Draw(erase).rectangle(box,fill=255)
    erase = erase.filter(ImageFilter.GaussianBlur(1.5))
    restored = repair_texture(painting,erase,donor)
    bounds = erase.getbbox()
    patch = restored.crop(bounds).convert('RGBA')
    patch.putalpha(erase.crop(bounds))
    size = 16
    while size < max(patch.size): size *= 2
    padded = Image.new('RGBA',(size,size));padded.paste(patch,(0,0))
    l,t,r,b=bounds
    return padded,[l/w,t/h,r/w,b/h],[0,patch.width/size,0,patch.height/size]


def ridge_patch(painting, source, feather=12):
    """Keep a native mountain sample at full resolution for a painting gap.

    The renderer places it below the real zone paintings; only the otherwise
    blank gap is visible. The soft fringe prevents a rectangular sample edge.
    """
    w, h = painting.size
    l, t, r, b = source
    patch = painting.crop((round(l * w), round(t * h), round(r * w), round(b * h))).convert('RGBA')
    y, x = np.mgrid[:patch.height, :patch.width]
    edge = np.minimum.reduce((x, y, patch.width - 1 - x, patch.height - 1 - y))
    alpha = np.clip(edge / feather, 0, 1)
    alpha = alpha * alpha * (3 - 2 * alpha)
    patch.putalpha(Image.fromarray(np.uint8(alpha * 255)))
    size = 16
    while size < max(patch.size): size *= 2
    padded = Image.new('RGBA', (size, size))
    padded.paste(patch)
    return padded, [0, patch.width / size, 0, patch.height / size]
