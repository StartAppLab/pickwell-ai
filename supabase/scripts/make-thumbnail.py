"""Bounded, orientation-correct front-package derivative; no generative editing."""
import hashlib
import io
import json
import os
import sys
import warnings
from pathlib import Path
from PIL import Image, ImageOps

MAX_INPUT = 5 * 1024 * 1024
MAX_PIXELS = 2400 * 2400
MAX_OUTPUT = 65536
Image.MAX_IMAGE_PIXELS = MAX_PIXELS

def thumbnail(source):
    if not 0 < len(source) <= MAX_INPUT:
        raise ValueError('image_size')
    with warnings.catch_warnings():
        warnings.simplefilter('error', Image.DecompressionBombWarning)
        with Image.open(io.BytesIO(source), formats=['JPEG', 'PNG']) as original:
            if getattr(original, 'n_frames', 1) != 1 or not (0 < original.width <= 2400 and 0 < original.height <= 2400):
                raise ValueError('image_dimensions')
            original.load()
            image = ImageOps.exif_transpose(original).convert('RGBA')
            background = Image.new('RGBA', image.size, 'white')
            background.alpha_composite(image)
            image = background.convert('RGB')
            image.info.clear()
            for edge in (384, 256, 192):
                image.thumbnail((edge, edge), Image.Resampling.LANCZOS)
                for quality in (78, 65, 50):
                    output = io.BytesIO()
                    image.save(output, format='JPEG', quality=quality, optimize=True, exif=b'')
                    data = output.getvalue()
                    if len(data) <= MAX_OUTPUT:
                        return data, {'width': image.width, 'height': image.height, 'bytes': len(data),
                                      'sha256': hashlib.sha256(data).hexdigest(), 'mime': 'image/jpeg',
                                      'generator': 'front-thumbnail-v1'}
    raise ValueError('thumbnail_size')

def main():
    source, target = map(Path, sys.argv[1:3])
    if source.stat().st_size > MAX_INPUT:
        raise ValueError('image_size')
    data, metadata = thumbnail(source.read_bytes())
    # Exclusive create prevents replacing any operator/user file.
    fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'wb') as output:
        output.write(data)
    print(json.dumps(metadata))

if __name__ == '__main__':
    try:
        main()
    except Exception:
        print('Thumbnail generation failed; no source image changed.', file=sys.stderr)
        sys.exit(1)
