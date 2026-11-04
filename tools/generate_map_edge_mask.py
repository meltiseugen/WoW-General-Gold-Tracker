"""Generate GGT's original feather mask (uncompressed RGBA TGA, no source art)."""
import struct
from pathlib import Path


def generate(path: Path, size: int = 128, locality: bool = False) -> None:
    pixels = bytearray()
    for y in range(size):
        for x in range(size):
            if locality:
                nx, ny = abs((x+.5)/size*2-1), abs((y+.5)/size*2-1)
                radius = (nx**4+ny**4)**.25
                t = max(0,min(1,(1-radius)/.35))
            else:
                distance = min(x + 0.5, y + 0.5, size - x - 0.5, size - y - 0.5)
                t = min(1.0, distance / (size * 0.08))
            alpha = round(255 * t * t * (3 - 2 * t))
            pixels.extend((255, 255, 255, alpha))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, size, size, 32, 0x28) + pixels)


if __name__ == "__main__":
    generate(Path("UI/Maps/Media/EdgeFade.tga"))
    generate(Path("UI/Maps/Media/LocalityFade.tga"), locality=True)
