import unittest
import os
import tempfile
import uuid
from src import abasm
from src import cdt
from src import dsk


class SafeEvaluateTestCase(unittest.TestCase):
    """Unit tests for the safe expression evaluator that replaced eval()."""

    def _check(self, expr, expected):
        self.assertEqual(abasm.safe_evaluate(expr), expected,
                         "unexpected value for expression: " + expr)

    # Expressions accepted by the classic eval() must survive in the new one

    def test_arithmetic(self):
        self._check("16*8", 128)
        self._check("3+4*5", 23)          # Python precedence (documented)
        self._check("(3+4)*5", 35)
        self._check("100-42", 58)
        self._check("10//3", 3)
        self._check("10%3", 1)            # produced by the MOD keyword
        self._check("0xC000+0x50*(0//8)", 49152)

    def test_unary(self):
        self._check("-5", -5)
        self._check("+7", 7)
        self._check("~0", -1)
        self._check("-(3+4)", -7)

    def test_bitwise(self):
        self._check("0x3F&0xC0", 0)       # produced by the AND keyword
        self._check("3|4", 7)             # produced by the OR keyword
        self._check("5^3", 6)             # produced by the XOR keyword
        self._check("1<<4", 16)
        self._check("256>>2", 64)

    def test_comparisons(self):
        self._check("5==5", 1)
        self._check("5!=6", 1)
        self._check("5!=5", 0)
        self._check("3<4", 1)
        self._check("4<=4", 1)
        self._check("5>4", 1)
        self._check("5>=5", 1)
        self._check("1<2<3", 1)           # chained comparison
        self._check("1<2>3", 0)

    def test_boolops(self):
        # not reachable from assembly sources (words are resolved as symbols
        # before evaluation) but kept compatible with the old eval()
        self._check("1 and 2", 2)
        self._check("0 and 2", 0)
        self._check("0 or 7", 7)
        self._check("0 or 0", 0)

    def test_whitespace_tolerated(self):
        self._check(" 4620 ", 4620)
        self._check("\t16 * 8\t", 128)

    def test_int_conversion_of_booleans(self):
        # comparisons evaluate to True/False and must reduce to 1/0
        self.assertEqual(abasm.safe_evaluate("2==2"), 1)
        self.assertIsInstance(abasm.safe_evaluate("2==2"), int)

    # Anything that is not plain integer arithmetic must be rejected

    def test_rejects_names_and_calls(self):
        for expr in ["__import__('os').system('calc')", "open('x.txt')",
                     "os.system('x')", "abs(-1)", "int('1')", "x", "True_",
                     "().__class__"]:
            with self.assertRaises((ValueError, SyntaxError),
                                   msg="expression should be rejected: " + expr):
                abasm.safe_evaluate(expr)

    def test_rejects_forbidden_literals_and_syntax(self):
        for expr in ["'abc'", '"abc"', "1.5", "0x1.5p1", "[1]", "(1,)",
                     "{1:2}", "1 if 1 else 2", "lambda: 1", "1;2",
                     "9**9**9",          # DoS through power operator
                     "10/3",             # true division (must be //)
                     "1e400"]:
            with self.assertRaises((ValueError, SyntaxError),
                                   msg="expression should be rejected: " + expr):
                abasm.safe_evaluate(expr)


class AssemblerInjectionTestCase(unittest.TestCase):
    """Assembly sources must never execute code inside the assembler."""

    @classmethod
    def setUpClass(cls):
        abasm.create_opdict()

    def _write_asm(self, content):
        tmp = os.path.join(tempfile.gettempdir(), str(uuid.uuid4()) + '.asm')
        with open(tmp, 'w') as f:
            f.write(content)
        return tmp

    def _expect_rejected(self, expression):
        # {victim} in the expression is replaced by a path which must never
        # be created: if it exists after assembly, code was executed
        sentinel = os.path.join(tempfile.gettempdir(),
                                str(uuid.uuid4()) + '.pwned')
        tmp = self._write_asm(f"""
org &4000
db {expression.format(victim=sentinel)}
""")
        out = tmp.replace('.asm', '.bin')
        try:
            with self.assertRaises((RuntimeError, SystemExit)):
                abasm.assemble(tmp, out, [], 0x4000)
            self.assertFalse(os.path.exists(sentinel),
                             "injected code was executed!")
        finally:
            if os.path.exists(tmp):
                os.unlink(tmp)
            if os.path.exists(out):
                os.unlink(out)
            if os.path.exists(sentinel):
                os.unlink(sentinel)

    def test_import_injection(self):
        self._expect_rejected(
            "__import__('os').system('cmd /c echo x> {victim}')")

    def test_open_injection(self):
        self._expect_rejected(
            "open('{victim}', 'w').write('pwned')")

    def test_attribute_injection(self):
        self._expect_rejected("().__class__.__bases__")

    def test_lambda_injection(self):
        self._expect_rejected("(lambda: 1)()")

    def test_undefined_symbol_still_aborts(self):
        self._expect_rejected("NOT_DEFINED_AT_AND_MAYHEM")


class MapFileParsingTestCase(unittest.TestCase):
    """dsk/cdt consume ABASM map files: they must be parsed as data."""

    def _write_map(self, content):
        tmp = os.path.join(tempfile.gettempdir(), str(uuid.uuid4()) + '.map')
        with open(tmp, 'w') as f:
            f.write(content)
        return tmp

    def test_valid_map_is_read(self):
        tmp = self._write_map("{'MAIN': 4608, 'HELLO': 4620}")
        try:
            for reader in (dsk.run_read_mapfile, cdt.run_read_mapfile):
                self.assertEqual(reader(tmp),
                                 {'MAIN': 4608, 'HELLO': 4620})
        finally:
            os.unlink(tmp)

    def test_malicious_map_does_not_execute(self):
        sentinel = os.path.join(tempfile.gettempdir(),
                                str(uuid.uuid4()) + '.pwned')
        payload = "{'MAIN': __import__('os').system('cmd /c echo x> " + \
                  sentinel.replace('\\', '\\\\') + "')}"
        tmp = self._write_map(payload)
        try:
            for reader in (dsk.run_read_mapfile, cdt.run_read_mapfile):
                with self.assertRaises(SystemExit):
                    reader(tmp)
            self.assertFalse(os.path.exists(sentinel),
                             "injected map file code was executed!")
        finally:
            os.unlink(tmp)
            if os.path.exists(sentinel):
                os.unlink(sentinel)

    def test_malformed_map_exits_cleanly(self):
        for content in ["{'MAIN': ", "not a dict at all ]", ""]:
            tmp = self._write_map(content)
            try:
                for reader in (dsk.run_read_mapfile, cdt.run_read_mapfile):
                    with self.assertRaises(SystemExit):
                        reader(tmp)
            finally:
                os.unlink(tmp)


if __name__ == "__main__":
    unittest.main()
