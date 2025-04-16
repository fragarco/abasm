import unittest
import os
import glob
from src import abasm

class CodeExamples(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        testdir = os.path.dirname(__file__)
        cls.refdir = os.path.join(testdir, "refs")
        cls.outdir = os.path.join(testdir, "outputs")
        extensions = ["*.bin", "*.map", "*.lst"]
        for ext in extensions:
            removeexpr = os.path.join(cls.outdir, ext)
            for file in glob.glob(removeexpr): os.remove(file)
        abasm.create_opdict()

    def _compare_bins(self, infile, outfile):
        infile = os.path.join(self.refdir, infile)
        outfile = os.path.join(self.outdir, outfile)
        try:
            abasm.assemble(infile, outfile, [], 0x1200)
        except Exception as e:
            self.fail("Assembling process was aborted " + str(e))
        try:
            infile = infile.replace(".asm", ".bin")
            with open(infile, "rb") as fd:
                refbin = fd.read()
            with open(outfile, "rb") as fd:
                newbin = fd.read()
        except Exception as e:
            self.fail("Error accesing to the binary files " + str(e))
        self.assertEqual(len(refbin), len(newbin), "binary lengths are different")
        for i in range(0, len(refbin)):
            self.assertEqual(refbin[i], newbin[i], "binary files content is different")

    def test_chars(self):
        self._compare_bins("chars.asm", "chars.bin")

    def test_game(self):
        self._compare_bins("game.asm", "game.bin")

    def test_hello(self):
        self._compare_bins("hello.asm", "hello.bin")

    def test_macros(self):
        self._compare_bins("macros.asm", "macros.bin")

    def test_real(self):
        self._compare_bins("real.asm", "real.bin")

    def test_repeat(self):
        self._compare_bins("repeat.asm", "repeat.bin")

    def test_sprite(self):
        self._compare_bins("sprite.asm", "sprite.bin")

    def test_directives(self):
        self._compare_bins("directives.asm", "directives.bin")

    def test_iflabel(self):
        self._compare_bins("iflabel.asm", "iflabel.bin")

    def test_opcodes(self):
        self._compare_bins("opcodes.asm", "opcodes.bin")

if __name__ == "__main__":
    unittest.main()
