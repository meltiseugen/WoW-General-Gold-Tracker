"""Write alpha masks as mipmapped BLP2/BC3 using Pillow's native BC encoder.

The BLP container is authored here. No reference-addon implementation or texture
is used. See Pillow's BlpImagePlugin and DdsImagePlugin for format documentation.
"""
from io import BytesIO
import struct

from PIL import Image


def read_texture(path):
    """Decode client BC blocks with Pillow's native decoder; fall back for BLP1.

    BLP2 and DDS store the same BC1/BC2/BC3 blocks. Avoid the Python BLP block
    loop when assembling thousands of native map tiles for offline analysis.
    """
    data = path.read_bytes()
    if data[:4] == b'BLP2' and data[8] == 2:
        alpha_depth, alpha_encoding = data[9:11]
        kind = 1 if alpha_encoding == 0 else 2 if alpha_encoding == 1 else 3 if alpha_encoding == 7 else None
        if kind:
            width,height=struct.unpack_from('<2I',data,12)
            offset=struct.unpack_from('<I',data,20)[0]
            length=struct.unpack_from('<I',data,84)[0]
            image=Image.frombytes('RGBA',(width,height),data[offset:offset+length],'bcn',(kind,('DXT1','DXT3','DXT5')[kind-1]))
            if kind == 1 and not alpha_depth: image.putalpha(255)
            return image
    with Image.open(path) as image: return image.convert('RGBA')


def save_mask(alpha, path):
    if alpha.width != alpha.height or alpha.width & (alpha.width-1):
        raise ValueError("Mask dimensions must be square powers of two")
    rgba = Image.new("RGBA", alpha.size, (255, 255, 255, 255))
    rgba.putalpha(alpha)
    save_texture(rgba, path)


def save_texture(image, path):
    blocks = []
    level = image.convert("RGBA")
    while True:
        dds = BytesIO()
        level.save(dds, format="DDS", pixel_format="DXT5")
        blocks.append(dds.getvalue()[128:])
        if level.width == 1: break
        level = level.resize((level.width//2, level.height//2), Image.Resampling.BOX)
    offsets, lengths, offset = [], [], 148+1024
    for block in blocks:
        offsets.append(offset); lengths.append(len(block)); offset += len(block)
    offsets += [0]*(16-len(offsets)); lengths += [0]*(16-len(lengths))
    path.write_bytes(struct.pack("<4sI4BII", b"BLP2", 1, 2, 8, 7, 1, image.width, image.height)
                     + struct.pack("<16I16I", *offsets, *lengths) + bytes(1024) + b"".join(blocks))
