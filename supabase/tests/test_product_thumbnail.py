"""Synthetic codec fixtures, never evidence of real product/publication accuracy."""
import importlib.util
import io
import unittest
from pathlib import Path
from PIL import Image
spec = importlib.util.spec_from_file_location('thumbnail', Path(__file__).parents[1] / 'scripts/make-thumbnail.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ProductThumbnailTests(unittest.TestCase):
    def encoded(self, size=(1200, 800), format='JPEG', **options):
        data = io.BytesIO()
        Image.new('RGB', size, (40, 100, 60)).save(data, format=format, **options)
        return data.getvalue()

    def test_jpeg_dimensions_ratio_size_and_metadata(self):
        data, meta = module.thumbnail(self.encoded())
        self.assertEqual((meta['width'], meta['height']), (384, 256))
        self.assertLessEqual(len(data), 65536)
        with Image.open(io.BytesIO(data)) as photo:
            self.assertEqual(photo.format, 'JPEG')
            self.assertFalse(photo.getexif())

    def test_all_exif_orientations_and_gps_metadata_removed(self):
        for orientation in range(1, 9):
            exif = Image.Exif()
            exif[274] = orientation
            exif[270] = 'Private fixture metadata'
            data, meta = module.thumbnail(self.encoded((300, 150), exif=exif))
            self.assertEqual((meta['width'], meta['height']), (150, 300) if orientation >= 5 else (300, 150))
            with Image.open(io.BytesIO(data)) as photo:
                self.assertEqual(dict(photo.getexif()), {})

    def test_png_transparency_and_no_upscale(self):
        raw = io.BytesIO()
        Image.new('RGBA', (40, 80), (0, 0, 0, 0)).save(raw, format='PNG')
        data, meta = module.thumbnail(raw.getvalue())
        self.assertEqual((meta['width'], meta['height']), (40, 80))
        with Image.open(io.BytesIO(data)) as photo:
            self.assertEqual(photo.getpixel((0, 0)), (255, 255, 255))

    def test_file_limit_format_and_decode_restrictions(self):
        for raw in [b'', b'bad JPEG', b'a' * (module.MAX_INPUT + 1), self.encoded((2, 2), 'GIF')]:
            with self.assertRaises(Exception):
                module.thumbnail(raw)

    def test_oversized_dimensions_and_decompression_bomb(self):
        for size in [(2401, 1), (3000, 3000)]:
            with self.assertRaises(Exception):
                module.thumbnail(self.encoded(size, 'PNG'))

    def test_animated_png_rejected(self):
        raw = io.BytesIO()
        Image.new('RGB', (10, 10), 'red').save(raw, format='PNG', save_all=True,
            append_images=[Image.new('RGB', (10, 10), 'blue')])
        with self.assertRaises(Exception):
            module.thumbnail(raw.getvalue())

if __name__ == '__main__':
    unittest.main()
