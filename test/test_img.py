import unittest
import os
import tempfile
from PIL import Image
from src import img


class CPCColorsConstantsTestCase(unittest.TestCase):
    """Test CPC color constants and their relationships."""

    def test_cpc_color_count(self):
        self.assertEqual(len(img.CPC_FW_COLORS), 27)

    def test_cpc_hw_color_mapping(self):
        # Every HW color maps to a valid FW index
        for hwid, fwid in img.CPC_HW_COLORS.items():
            self.assertGreaterEqual(fwid, 0)
            self.assertLessEqual(fwid, 26)

    def test_cpc_rgb_color_count(self):
        self.assertEqual(len(img.CPC_RGB_COLORS), 27)

    def test_color_tuples_valid(self):
        for _, rgb in img.CPC_FW_COLORS:
            self.assertTrue(all(0 <= c <= 255 for c in rgb))


class ImgConverterColorTestCase(unittest.TestCase):
    """Test ImgConverter color-related methods."""

    def setUp(self):
        # Default palette for mode 2 (2 colors: black and white)
        self.conv = img.ImgConverter(mode=2, palette=[0x14, 0x0B])

    def test_colors_per_mode(self):
        self.assertEqual(self.conv._colors_per_mode(0), 16)
        self.assertEqual(self.conv._colors_per_mode(1), 4)
        self.assertEqual(self.conv._colors_per_mode(2), 2)

    def test_color_distance_same(self):
        dist = self.conv._get_color_distance((0, 0, 0), (0, 0, 0))
        self.assertEqual(dist, 0)

    def test_color_distance_max(self):
        dist = self.conv._get_color_distance((0, 0, 0), (255, 255, 255))
        self.assertEqual(dist, 765)

    def test_findcolor_black(self):
        colors = [(0, 0, 0), (255, 255, 255)]
        diff, idx = self.conv._findcolor((0, 0, 0), colors)
        self.assertEqual(idx, 0)
        self.assertEqual(diff, 0)

    def test_findcolor_white(self):
        colors = [(0, 0, 0), (255, 255, 255)]
        diff, idx = self.conv._findcolor((255, 255, 255), colors)
        self.assertEqual(idx, 1)
        self.assertEqual(diff, 0)

    def test_findcolor_nearest(self):
        colors = [(0, 0, 0), (255, 255, 255)]
        diff, idx = self.conv._findcolor((128, 128, 128), colors)
        # 128 is closer to 255 (diff=381) than to 0 (diff=384)
        self.assertEqual(idx, 1)

    def test_palette_too_large_mode2(self):
        with self.assertRaises(img.ConversionError):
            img.ImgConverter(mode=2, palette=[0x14, 0x0B, 0x04])

    def test_palette_too_large_mode1(self):
        with self.assertRaises(img.ConversionError):
            img.ImgConverter(mode=1, palette=[0x14, 0x0B, 0x04, 0x0C, 0x18])

    def test_palette_too_large_mode0(self):
        pal = [0x14, 0x0B, 0x04, 0x0C, 0x18, 0x00, 0x06, 0x15,
               0x1E, 0x0E, 0x0D, 0x05, 0x12, 0x16, 0x1A, 0x0A, 0x1B]
        with self.assertRaises(img.ConversionError):
            img.ImgConverter(mode=0, palette=pal)

    def test_invalid_palette_color(self):
        with self.assertRaises(img.ConversionError):
            img.ImgConverter(mode=2, palette=[0x14, 0xFF])


class ImgConverterConversionTestCase(unittest.TestCase):
    """Test ImgConverter conversion methods."""

    def _create_img(self, width, height, color):
        return Image.new('RGB', (width, height), color)

    def test_mode2_simple(self):
        """Mode 2: 8 pixels = 1 byte. Test 8x1 image."""
        palette = [0x14, 0x0B]  # black, white
        c = img.ImgConverter(mode=2, palette=palette)
        # 8 pixels: 4 black, 4 white -> should encode as 0x0F
        rgbimg = self._create_img(8, 1, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        data = c._img2mode()
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0], 0x00)  # all black

    def test_mode2_mixed(self):
        """Mode 2: mixed black/white pixels."""
        palette = [0x14, 0x0B]  # black, white
        c = img.ImgConverter(mode=2, palette=palette)
        pixels = [(0, 0, 0), (255, 255, 255)] * 4  # alternating B,W,B,W...
        rgbimg = Image.new('RGB', (8, 1))
        for x in range(8):
            rgbimg.putpixel((x, 0), pixels[x])
        c.build_cpcimg(rgbimg, 2, '')
        data = c._img2mode()
        self.assertEqual(len(data), 1)
        # Alternating black/white pixels produce 10101010 = 0xAA
        self.assertEqual(data[0], 0xAA)

    def test_mode1_simple(self):
        """Mode 1: 4 pixels per byte. Test 4x1 image."""
        palette = [0x14, 0x0B, 0x04, 0x0C]
        c = img.ImgConverter(mode=1, palette=palette)
        rgbimg = self._create_img(4, 1, (0, 0, 0))
        c.build_cpcimg(rgbimg, 1, '')
        data = c._img2mode()
        self.assertEqual(len(data), 1)

    def test_image_size_validation(self):
        """Test that image size matches expected dimensions."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        rgbimg = self._create_img(16, 16, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        self.assertEqual(len(c.img), 16 * 16)

    def test_automatic_palette(self):
        """Test automatic palette generation uses most common colors."""
        c = img.ImgConverter()
        # Create image with distinct black pixels
        rgbimg = self._create_img(10, 10, (0, 0, 0))
        palette = c.build_palette(rgbimg, 0)
        # Should include black (0x14)
        self.assertIn(0x14, palette)

    def test_write_bin_creates_file(self):
        """Test that write_bin creates a valid bin file."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        rgbimg = self._create_img(8, 8, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_bin(target)
            self.assertTrue(os.path.exists(target + '.bin'))
            self.assertTrue(os.path.exists(target + '.bin.info'))
            with open(target + '.bin', 'rb') as f:
                data = f.read()
            self.assertEqual(len(data), 8)  # 8 pixels wide = 1 byte * 8 rows

    def test_write_asm_creates_file(self):
        """Test that write_asm creates an asm file."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        rgbimg = self._create_img(8, 8, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_asm(target)
            self.assertTrue(os.path.exists(target + '.asm'))
            # Check it contains the image data
            with open(target + '.asm', 'r') as f:
                content = f.read()
            self.assertIn('db', content)

    def test_write_bas_creates_file(self):
        """Test that write_bas creates a bas file."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        # 16x8 image -> 16 bytes per row, 8 rows -> 128 bytes (even)
        rgbimg = self._create_img(16, 8, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_bas(target)
            self.assertTrue(os.path.exists(target + '.bas'))

    def test_write_c_creates_files(self):
        """Test that write_c creates .c and .h files."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        rgbimg = self._create_img(8, 8, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_c(target)
            self.assertTrue(os.path.exists(target + '.c'))
            self.assertTrue(os.path.exists(target + '.h'))
            with open(target + '.c', 'r') as f:
                content = f.read()
            self.assertIn('IMG', content)

    def test_write_scn_wrong_size(self):
        """Test that SCN format requires exact dimensions."""
        pal = [0x14, 0x0B, 0x04, 0x0C, 0x18, 0x00, 0x06, 0x15,
               0x1E, 0x0E, 0x0D, 0x05, 0x12, 0x16, 0x1A, 0x0A]
        c = img.ImgConverter(mode=0, palette=pal)
        rgbimg = self._create_img(10, 10, (0, 0, 0))
        c.build_cpcimg(rgbimg, 0, '')
        with self.assertRaises(img.ConversionError):
            c.write_scn('/tmp/test')

    def test_write_scn_correct_size(self):
        """Test SCN generation with correct dimensions."""
        pal = [0x14, 0x0B, 0x04, 0x0C, 0x18, 0x00, 0x06, 0x15,
               0x1E, 0x0E, 0x0D, 0x05, 0x12, 0x16, 0x1A, 0x0A]
        c = img.ImgConverter(mode=0, palette=pal)
        rgbimg = self._create_img(160, 200, (0, 0, 0))
        c.build_cpcimg(rgbimg, 0, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_scn(target)
            self.assertTrue(os.path.exists(target + '.scn'))

    def test_write_info_contains_palette(self):
        """Test that .info file contains palette info."""
        palette = [0x14, 0x0B]
        c = img.ImgConverter(mode=2, palette=palette)
        rgbimg = self._create_img(8, 8, (0, 0, 0))
        c.build_cpcimg(rgbimg, 2, '')
        with tempfile.TemporaryDirectory() as tmpdir:
            target = os.path.join(tmpdir, 'test')
            c.write_bin(target)
            with open(target + '.bin.info', 'r') as f:
                info = f.read()
            self.assertIn('MODE: 2', info)
            self.assertIn('WIDTH: 8', info)
            self.assertIn('HEIGHT: 8', info)


if __name__ == "__main__":
    unittest.main()
