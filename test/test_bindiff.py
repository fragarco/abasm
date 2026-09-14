import unittest
import os
import tempfile
from src import bindiff


class BindiffCompareTestCase(unittest.TestCase):
    """Test the _compare_bins function."""

    def test_identical_files(self):
        tmp = self._write_tmp(b'\x01\x02\x03\x04\x05')
        try:
            result = bindiff._compare_bins(tmp, tmp)
            self.assertEqual(result, 0)
        finally:
            os.unlink(tmp)

    def test_different_content(self):
        tmp1 = self._write_tmp(b'\x01\x02\x03\x04\x05')
        tmp2 = self._write_tmp(b'\x01\x02\xFF\x04\x05')
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 1)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_different_size(self):
        tmp1 = self._write_tmp(b'\x01\x02\x03')
        tmp2 = self._write_tmp(b'\x01\x02\x03\x04\x05')
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 1)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_completely_different(self):
        tmp1 = self._write_tmp(b'\x00\x00\x00')
        tmp2 = self._write_tmp(b'\xFF\xFF\xFF')
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 1)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_empty_files(self):
        tmp1 = self._write_tmp(b'')
        tmp2 = self._write_tmp(b'')
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 0)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_one_empty(self):
        tmp1 = self._write_tmp(b'')
        tmp2 = self._write_tmp(b'\x00')
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 1)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_nonexistent_file(self):
        result = bindiff._compare_bins("/nonexistent/file1.bin", "/nonexistent/file2.bin")
        self.assertEqual(result, 1)

    def test_large_files(self):
        data = bytearray(range(256)) * 100  # 25600 bytes
        tmp1 = self._write_tmp(bytes(data))
        tmp2 = self._write_tmp(bytes(data))
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 0)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def test_single_byte_difference_at_end(self):
        data1 = bytearray(range(256))
        data2 = bytearray(range(256))
        data2[255] = (data2[255] + 1) % 256
        tmp1 = self._write_tmp(bytes(data1))
        tmp2 = self._write_tmp(bytes(data2))
        try:
            result = bindiff._compare_bins(tmp1, tmp2)
            self.assertEqual(result, 1)
        finally:
            os.unlink(tmp1)
            os.unlink(tmp2)

    def _write_tmp(self, data):
        with tempfile.NamedTemporaryFile(delete=False) as f:
            f.write(data)
            return f.name


if __name__ == "__main__":
    unittest.main()
