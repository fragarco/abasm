import unittest
import os
import tempfile
import math
from src import dsk

# Module constants used in tests
CPM_DELETED = 0xE5
CPM_MIN_SECTOR = 0xC1
CPM_PAGE_BYTES = 128
CPM_CLUSTER_PAGES = 8
DEF_SECTORS = 9
DEF_TRACKS = 40
DEF_SIDES = 1
DEF_TRACK_SZ = 256 + 512 * 9


class DiskHeaderTestCase(unittest.TestCase):
    """Test DiskHeader compose/set/check round-trips."""

    def test_compose_default_header_size(self):
        h = dsk.DiskHeader(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)
        data = h.compose()
        self.assertEqual(len(data), 256)

    def test_compose_set_round_trip(self):
        h = dsk.DiskHeader(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)
        data = h.compose()
        h2 = dsk.DiskHeader(0, 0, 0)
        remainder = h2.set(data)
        self.assertEqual(len(remainder), 0)
        self.assertEqual(h2.tracks, DEF_TRACKS)
        self.assertEqual(h2.sztrack, DEF_TRACK_SZ)
        self.assertEqual(h2.sides, DEF_SIDES)
        self.assertIn(b'MV - CPCEMU', h2.title)

    def test_check_valid(self):
        h = dsk.DiskHeader(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)
        h.compose()
        h.check(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)  # should not raise

    def test_check_wrong_title(self):
        h = dsk.DiskHeader(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)
        h.title = b'INVALID TITLE                       '
        with self.assertRaises(dsk.FormatError):
            h.check(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)

    def test_check_wrong_sides(self):
        h = dsk.DiskHeader(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)
        h.sides = 2
        with self.assertRaises(dsk.FormatError):
            h.check(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)

    def test_check_too_few_tracks(self):
        h = dsk.DiskHeader(10, DEF_TRACK_SZ, DEF_SIDES)
        with self.assertRaises(dsk.FormatError):
            h.check(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)

    def test_check_wrong_sztrack(self):
        h = dsk.DiskHeader(DEF_TRACKS, 999, DEF_SIDES)
        with self.assertRaises(dsk.FormatError):
            h.check(DEF_TRACKS, DEF_TRACK_SZ, DEF_SIDES)

    def test_set_too_small(self):
        h = dsk.DiskHeader(0, 0, 0)
        with self.assertRaises(dsk.FormatError):
            h.set(bytearray(100))


class TrackSectorInfoTestCase(unittest.TestCase):
    """Test TrackSectorInfo compose/set/check.

    Constructor: TrackSectorInfo(sector, track, side, basetrack)
    """

    def test_compose_size(self):
        s = dsk.TrackSectorInfo(0, 0, 0, CPM_MIN_SECTOR)
        data = s.compose()
        self.assertEqual(len(data), 8)

    def test_compose_set_round_trip(self):
        # sector=5, track=3, side=0, basetrack=CPM_MIN_SECTOR
        s = dsk.TrackSectorInfo(5, 3, 0, CPM_MIN_SECTOR)
        data = s.compose()
        s2 = dsk.TrackSectorInfo(0, 0, 0, CPM_MIN_SECTOR)
        s2.set(data)
        self.assertEqual(s2.C, 3)
        self.assertEqual(s2.H, 0)
        self.assertEqual(s2.R, CPM_MIN_SECTOR + 5)
        self.assertEqual(s2.N, 2)

    def test_check_valid(self):
        s = dsk.TrackSectorInfo(0, 0, 0, CPM_MIN_SECTOR)
        s.check(0)  # should not raise

    def test_check_wrong_track(self):
        # sector=0, track=5, side=0, basetrack=CPM_MIN_SECTOR
        s = dsk.TrackSectorInfo(0, 5, 0, CPM_MIN_SECTOR)
        with self.assertRaises(dsk.FormatError):
            s.check(0)

    def test_check_wrong_N(self):
        s = dsk.TrackSectorInfo(0, 0, 0, CPM_MIN_SECTOR)
        s.N = 0xFF
        with self.assertRaises(dsk.FormatError):
            s.check(0)

    def test_check_wrong_H(self):
        s = dsk.TrackSectorInfo(0, 0, 1, CPM_MIN_SECTOR)
        with self.assertRaises(dsk.FormatError):
            s.check(0)

    def test_check_R_out_of_range(self):
        s = dsk.TrackSectorInfo(0, 0, 0, 0xAA)
        with self.assertRaises(dsk.FormatError):
            s.check(0)


class TrackHeaderTestCase(unittest.TestCase):
    """Test TrackHeader compose/set/check."""

    def test_compose_size(self):
        t = dsk.TrackHeader(0, DEF_SECTORS, CPM_MIN_SECTOR, 0)
        data = t.compose()
        self.assertEqual(len(data), 256)

    def test_compose_set_round_trip(self):
        t = dsk.TrackHeader(5, DEF_SECTORS, CPM_MIN_SECTOR, 0)
        data = t.compose()
        t2 = dsk.TrackHeader(0, DEF_SECTORS, CPM_MIN_SECTOR, 0)
        remainder = t2.set(DEF_SECTORS, data)
        self.assertEqual(len(remainder), 0)
        self.assertEqual(t2.track, 5)
        self.assertEqual(t2.sectors, DEF_SECTORS)
        self.assertEqual(t2.side, 0)

    def test_check_valid(self):
        t = dsk.TrackHeader(0, DEF_SECTORS, CPM_MIN_SECTOR, 0)
        t.check()  # should not raise

    def test_check_wrong_title(self):
        t = dsk.TrackHeader(0, DEF_SECTORS, CPM_MIN_SECTOR, 0)
        t.title = b'INVALID!'
        with self.assertRaises(dsk.FormatError):
            t.check()


class TrackDataTestCase(unittest.TestCase):
    """Test TrackData compose/set."""

    def test_compose_size(self):
        td = dsk.TrackData(DEF_SECTORS, 0xE5)
        data = td.compose()
        self.assertEqual(len(data), 512 * DEF_SECTORS)

    def test_fill_value(self):
        td = dsk.TrackData(DEF_SECTORS, 0xAB)
        data = td.compose()
        self.assertTrue(all(b == 0xAB for b in data))

    def test_set_and_get_sector_data(self):
        td = dsk.TrackData(DEF_SECTORS, 0x00)
        sector_data = bytearray(range(256))
        td.set_sector_data(0, bytearray(sector_data))  # pass a copy (mutates in place)
        retrieved = td.get_sector_data(0, 256)
        self.assertEqual(retrieved, sector_data)

    def test_set_sector_data_padding(self):
        td = dsk.TrackData(DEF_SECTORS, 0x00)
        small = bytearray(b'\x01\x02\x03')
        td.set_sector_data(2, small)
        retrieved = td.get_sector_data(2, 5)
        self.assertEqual(len(retrieved), 5)
        self.assertEqual(retrieved[0], 1)
        self.assertEqual(retrieved[1], 2)
        self.assertEqual(retrieved[2], 3)
        self.assertEqual(retrieved[3], 0)  # padded
        self.assertEqual(retrieved[4], 0)

    def test_check_wrong_size(self):
        td = dsk.TrackData(DEF_SECTORS, 0x00)
        td.data = bytearray(100)  # too small
        with self.assertRaises(dsk.FormatError):
            td.check()


class TrackTestCase(unittest.TestCase):
    """Test Track compose/set round-trip."""

    def test_compose_size(self):
        t = dsk.Track(0, DEF_SECTORS, CPM_MIN_SECTOR)
        data = t.compose()
        self.assertEqual(len(data), DEF_TRACK_SZ)

    def test_compose_set_round_trip(self):
        t = dsk.Track(10, DEF_SECTORS, CPM_MIN_SECTOR)
        data = t.compose()
        t2 = dsk.Track(0, DEF_SECTORS, CPM_MIN_SECTOR)
        remainder = t2.set(DEF_SECTORS, data)
        self.assertEqual(len(remainder), 0)
        self.assertEqual(t2.track, 10)

    def test_set_sector_data_via_track(self):
        t = dsk.Track(0, DEF_SECTORS, CPM_MIN_SECTOR)
        payload = bytearray(b'HELLO')
        t.set_sector_data(CPM_MIN_SECTOR, bytearray(b'HELLO'))  # pass a copy
        retrieved = t.get_sector_data(CPM_MIN_SECTOR, 5)
        self.assertEqual(retrieved, payload)


class DiskTestCase(unittest.TestCase):
    """Test Disk compose/set/write/read round-trips."""

    def test_compose_size(self):
        disk = dsk.Disk()
        data = disk.compose()
        expected = 256 + DEF_TRACKS * DEF_TRACK_SZ
        self.assertEqual(len(data), expected)

    def test_compose_set_round_trip(self):
        disk = dsk.Disk()
        data = disk.compose()
        disk2 = dsk.Disk()
        disk2.set(data)
        self.assertEqual(disk2.ntracks, DEF_TRACKS)
        self.assertEqual(disk2.nsides, DEF_SIDES)

    def test_format_resets_disk(self):
        disk = dsk.Disk()
        disk.format()
        data = disk.compose()
        self.assertEqual(len(data), 256 + DEF_TRACKS * DEF_TRACK_SZ)

    def test_check_valid_disk(self):
        disk = dsk.Disk()
        disk.check()  # should not raise

    def test_add_and_retrieve_content(self):
        disk = dsk.Disk()
        payload = bytearray(range(256))
        disk.add_content([(0, 0)], payload)
        retrieved = disk.get_content(0, 0, 256)
        self.assertEqual(retrieved, payload)

    def test_read_nonexistent_file(self):
        disk = dsk.Disk()
        ok = disk.read("/nonexistent/path/file.dsk")
        self.assertFalse(ok)

    def test_get_dirtable(self):
        disk = dsk.Disk()
        dt = disk.get_dirtable()
        self.assertIsInstance(dt, dsk.DirTable)
        self.assertEqual(len(dt.entries), 64)

    def test_set_dirtable_round_trip(self):
        disk = dsk.Disk()
        dt = dsk.DirTable()
        dt.entries[0].status = 0
        dt.entries[0].name = bytearray(b'TEST    ')
        dt.entries[0].ext = bytearray(b'BIN')
        dt.entries[0].pages = 4
        disk.set_dirtable(dt)
        dt2 = disk.get_dirtable()
        self.assertEqual(dt2.entries[0].name, dt.entries[0].name)


class DirEntryTestCase(unittest.TestCase):
    """Test DirEntry compose/set/check."""

    def test_compose_deleted_size(self):
        e = dsk.DirEntry(0)
        data = e.compose()
        self.assertEqual(len(data), 32)
        # Deleted entries are all 0xE5
        self.assertTrue(all(b == CPM_DELETED for b in data))

    def test_compose_active_entry(self):
        e = dsk.DirEntry(5)
        e.status = 0
        e.name = bytearray(b'PROG    ')
        e.ext = bytearray(b'BIN')  # 3 bytes only
        e.pages = 8
        e.clusters = bytearray([1, 2, 3] + [0x00] * 13)
        data = e.compose()
        self.assertEqual(len(data), 32)
        self.assertEqual(data[0], 0)  # status

    def test_compose_set_round_trip(self):
        e = dsk.DirEntry(3)
        e.status = 1
        e.name = bytearray(b'MYFILE  ')
        e.ext = bytearray(b'TXT')  # 3 bytes only
        e.pages = 4
        e.clusters = bytearray([10] + [0x00] * 15)
        data = e.compose()
        e2 = dsk.DirEntry(0)
        e2.set(data)
        self.assertEqual(e2.status, 1)
        self.assertEqual(e2.name, e.name)
        self.assertEqual(e2.ext, e.ext)
        self.assertEqual(e2.pages, 4)

    def test_get_filename(self):
        e = dsk.DirEntry(0)
        e.status = 0
        e.name = bytearray(b'HELLO   ')
        e.ext = bytearray(b'TXT')
        self.assertEqual(e.get_filename(), 'HELLO.TXT')

    def test_get_filename_no_ext(self):
        e = dsk.DirEntry(0)
        e.status = 0
        e.name = bytearray(b'NOEXT   ')
        e.ext = bytearray(b'   ')
        self.assertEqual(e.get_filename(), 'NOEXT.')

    def test_get_clusters(self):
        e = dsk.DirEntry(0)
        e.pages = 0
        self.assertEqual(e.get_clusters(), 0)
        e.pages = 1
        self.assertEqual(e.get_clusters(), 1)
        e.pages = 8
        self.assertEqual(e.get_clusters(), 1)
        e.pages = 9
        self.assertEqual(e.get_clusters(), 2)
        e.pages = 128
        self.assertEqual(e.get_clusters(), 16)

    def test_to_sectors(self):
        e = dsk.DirEntry(0)
        e.pages = 8
        e.clusters = bytearray([0] + [0x00] * 15)
        sectors = e.to_sectors(0)
        # cluster 0 -> sectors 0 and 1 of track 0
        self.assertEqual(len(sectors), 2)


class DirTableTestCase(unittest.TestCase):
    """Test DirTable compose/set/allocate."""

    def test_compose_size(self):
        dt = dsk.DirTable()
        data = dt.compose()
        self.assertEqual(len(data), 64 * 32)  # 2048 bytes

    def test_all_deleted(self):
        dt = dsk.DirTable()
        data = dt.compose()
        self.assertTrue(all(b == CPM_DELETED for b in data))

    def test_compose_set_round_trip(self):
        dt = dsk.DirTable()
        dt.entries[0].status = 0
        dt.entries[0].name = bytearray(b'TEST    ')
        dt.entries[0].ext = bytearray(b'BIN')
        dt.entries[0].pages = 4
        dt.entries[0].clusters = bytearray([5] + [0x00] * 15)
        data = dt.compose()
        dt2 = dsk.DirTable()
        dt2.set(data)
        self.assertEqual(dt2.entries[0].status, 0)
        self.assertEqual(dt2.entries[0].name, dt.entries[0].name)

    def test_can_allocate_empty(self):
        dt = dsk.DirTable()
        entry = dt.can_allocate(1024)
        self.assertEqual(entry, 0)  # first entry available

    def test_can_allocate_full(self):
        dt = dsk.DirTable()
        for e in dt.entries:
            e.status = 0
            e.name = bytearray(b'X       ')
            e.pages = 128
        # Disk is full, should return -1
        entry = dt.can_allocate(1024)
        self.assertEqual(entry, -1)

    def test_get_disk_clusters_empty(self):
        dt = dsk.DirTable()
        clusters, freekb = dt.get_disk_clusters()
        # First 2 clusters used by dir table
        self.assertFalse(clusters[0])
        self.assertFalse(clusters[1])
        # Rest should be free
        self.assertTrue(clusters[2])
        # Free space: 180K - 2K (dir) = 178K
        self.assertEqual(freekb, 178)

    def test_get_disk_clusters_with_entries(self):
        dt = dsk.DirTable()
        dt.entries[0].status = 0
        dt.entries[0].pages = 8  # 1K = 1 cluster
        dt.entries[0].clusters = bytearray([2] + [0x00] * 15)
        clusters, freekb = dt.get_disk_clusters()
        self.assertFalse(clusters[2])  # cluster 2 is used
        self.assertEqual(freekb, 177)  # 178 - 1 = 177

    def test_write_entries(self):
        dt = dsk.DirTable()
        sectors = dt.write_entries(0, "test.bin", 1024, 0, False, False)
        self.assertGreater(len(sectors), 0)
        self.assertEqual(dt.entries[0].status, 0)
        self.assertEqual(dt.entries[0].name, bytearray(b'TEST    '))
        self.assertEqual(dt.entries[0].ext, bytearray(b'BIN'))
        self.assertEqual(dt.entries[0].pages, 8)  # 1024/128 = 8 pages


class AmsdosHeadTestCase(unittest.TestCase):
    """Test AmsdosHead compose/set/check."""

    def test_compose_size(self):
        h = dsk.AmsdosHead()
        data = h.compose()
        self.assertEqual(len(data), 128)

    def test_compose_set_round_trip(self):
        h = dsk.AmsdosHead()
        h.user = 5
        h.file_name = bytearray(b'MYPROG  ')
        h.file_ext = bytearray(b'BIN')
        h.file_size = 1024
        h.addr_load = 0x4000
        h.addr_entry = 0x4000
        h.update_checksum()
        data = h.compose()
        h2 = dsk.AmsdosHead()
        h2.set(data)
        self.assertEqual(h2.user, 5)
        self.assertEqual(h2.file_name, h.file_name)
        self.assertEqual(h2.file_ext, h.file_ext)
        self.assertEqual(h2.file_size, 1024)
        self.assertEqual(h2.addr_load, 0x4000)
        self.assertEqual(h2.addr_entry, 0x4000)

    def test_checksum_valid(self):
        h = dsk.AmsdosHead()
        h.file_name = bytearray(b'TEST    ')
        h.file_ext = bytearray(b'BIN')
        h.file_size = 256
        h.update_checksum()
        self.assertTrue(h.is_valid_header())

    def test_checksum_invalid(self):
        h = dsk.AmsdosHead()
        h.file_name = bytearray(b'TEST    ')
        h.file_ext = bytearray(b'BIN')
        h.file_size = 256
        h.checksum = 0xDEAD  # wrong checksum
        self.assertFalse(h.is_valid_header())

    def test_empty_header_invalid(self):
        h = dsk.AmsdosHead()
        # All zeros -> should be invalid
        self.assertFalse(h.is_valid_header())

    def test_build_bin(self):
        h = dsk.AmsdosHead()
        with tempfile.NamedTemporaryFile(suffix='.bin', delete=False) as f:
            tmp = f.name
        try:
            h.build(0, tmp, 1024)
            self.assertEqual(h.user, 0)
            self.assertEqual(h.file_size, 1024)
            self.assertEqual(h.file_ext, bytearray(b'BIN'))
            self.assertTrue(h.is_valid_header())
        finally:
            os.unlink(tmp)

    def test_build_bas(self):
        h = dsk.AmsdosHead()
        with tempfile.NamedTemporaryFile(suffix='.bas', delete=False) as f:
            tmp = f.name
        try:
            h.build(0, tmp, 100)
            self.assertEqual(h.file_type, dsk.AMSDOS_BAS_TYPE)
            self.assertEqual(h.file_ext, bytearray(b'BAS'))
        finally:
            os.unlink(tmp)

    def test_build_long_name_truncated(self):
        h = dsk.AmsdosHead()
        with tempfile.NamedTemporaryFile(suffix='.EXE', delete=False) as f:
            tmp = f.name
        try:
            h.build(0, "VERYLONGNAME.EXE", 50)
            self.assertEqual(len(h.file_name), 8)
            self.assertEqual(h.file_name, bytearray(b'VERYLONG'))
        finally:
            os.unlink(tmp)

    def test_set_too_small(self):
        h = dsk.AmsdosHead()
        with self.assertRaises(dsk.FormatError):
            h.set(bytearray(64))

    def test_calculate_checksum_deterministic(self):
        h = dsk.AmsdosHead()
        h.file_name = bytearray(b'CHECKSUM')
        h.file_ext = bytearray(b'TST')
        cs1 = h.calculate_checksum()
        cs2 = h.calculate_checksum()
        self.assertEqual(cs1, cs2)  # deterministic


class DskAuxIntTestCase(unittest.TestCase):
    """Test the aux_int helper function."""

    def test_decimal(self):
        self.assertEqual(dsk.aux_int("123"), 123)

    def test_hex_prefix(self):
        self.assertEqual(dsk.aux_int("0xFF"), 255)

    def test_hex_0x_prefix(self):
        self.assertEqual(dsk.aux_int("0x4000"), 0x4000)

    def test_octal(self):
        self.assertEqual(dsk.aux_int("0o77"), 63)

    def test_binary(self):
        self.assertEqual(dsk.aux_int("0b1010"), 10)


class DskIntegrationTestCase(unittest.TestCase):
    """Integration tests that write/read full DSK files."""

    def test_create_write_read_disk(self):
        """Create a new disk, write it, read it back, and verify."""
        disk = dsk.Disk()
        with tempfile.NamedTemporaryFile(suffix='.dsk', delete=False) as f:
            tmp = f.name
        try:
            disk.write(tmp)
            self.assertTrue(os.path.exists(tmp))
            self.assertEqual(os.path.getsize(tmp), len(disk.compose()))
            disk2 = dsk.Disk()
            ok = disk2.read(tmp)
            self.assertTrue(ok)
            self.assertEqual(disk2.ntracks, DEF_TRACKS)
            disk2.check()  # should not raise
        finally:
            os.unlink(tmp)

    def test_format_then_write(self):
        """Format a disk, then write it."""
        disk = dsk.Disk()
        disk.format()
        with tempfile.NamedTemporaryFile(suffix='.dsk', delete=False) as f:
            tmp = f.name
        try:
            disk.write(tmp)
            disk2 = dsk.Disk()
            disk2.read(tmp)
            disk2.check()  # fresh formatted disk should pass
        finally:
            os.unlink(tmp)


if __name__ == "__main__":
    unittest.main()
