import unittest
import os
import tempfile
import uuid
from src import abasm


class AsmErrorTestCase(unittest.TestCase):
    """Test assembler error handling and edge cases.

    These tests write small .asm files and expect the assembler to
    raise RuntimeError when it encounters errors.
    """

    @classmethod
    def setUpClass(cls):
        abasm.create_opdict()

    def _write_asm(self, content):
        tmp = os.path.join(tempfile.gettempdir(), str(uuid.uuid4()) + '.asm')
        with open(tmp, 'w') as f:
            f.write(content)
        return tmp

    def _assemble_and_expect_error(self, asm_content):
        """Write asm content and expect assembly to fail."""
        tmp = self._write_asm(asm_content)
        try:
            with self.assertRaises((RuntimeError, SystemExit)):
                abasm.assemble(tmp, None, [], 0x4000)
        finally:
            os.unlink(tmp)

    def _assemble_and_expect_success(self, asm_content, expected_min_bytes=0):
        """Write asm content and expect assembly to succeed."""
        tmp = self._write_asm(asm_content)
        out = tmp.replace('.asm', '.bin')
        try:
            abasm.assemble(tmp, out, [], 0x4000)
            if expected_min_bytes > 0:
                with open(out, 'rb') as f:
                    data = f.read()
                self.assertGreaterEqual(len(data), expected_min_bytes)
        finally:
            os.unlink(tmp)
            if os.path.exists(out):
                os.unlink(out)

    # Error cases

    def test_undefined_label(self):
        """Using an undefined label should fail."""
        self._assemble_and_expect_error("""
org &4000
ld hl, NONEXISTENT_LABEL
""")

    def test_missing_operand(self):
        """Instruction requiring operand without one should fail."""
        self._assemble_and_expect_error("""
org &4000
ld a,
""")

    def test_invalid_opcode(self):
        """Non-existent opcode should fail."""
        self._assemble_and_expect_error("""
org &4000
FAKEOP A, B
""")

    def test_memory_overflow(self):
        """Code exceeding memory limit should fail."""
        self._assemble_and_expect_error("""
org &FF00
repeat 300
    db 0
rend
""")

    def test_mismatched_if_endif(self):
        """IF without matching ENDIF should fail."""
        self._assemble_and_expect_error("""
org &4000
let X = 1
if X
    db 0
""")

    def test_mismatched_while_wend(self):
        """WHILE without matching WEND should fail."""
        self._assemble_and_expect_error("""
org &4000
let X = 1
while X > 0
    db 0
""")

    def test_mismatched_repeat_rend(self):
        """REPEAT without matching REND should fail."""
        self._assemble_and_expect_error("""
org &4000
repeat 5
    db 0
""")

    def test_missing_endm(self):
        """MACRO without ENDM should fail."""
        self._assemble_and_expect_error("""
org &4000
macro MYMAC
    ld a, 0
""")

    # Success cases

    def test_empty_program(self):
        """A program with only ORG should fail (nothing assembled)."""
        self._assemble_and_expect_error("org &4000\n")

    def test_simple_instruction(self):
        """A single instruction should assemble."""
        self._assemble_and_expect_success("""
org &4000
ld a, 0
""", expected_min_bytes=2)

    def test_label_and_jump(self):
        """Labels and jumps should resolve correctly."""
        self._assemble_and_expect_success("""
org &4000
loop:
    jp loop
""", expected_min_bytes=3)

    def test_equ_definition(self):
        """EQU definitions should work."""
        self._assemble_and_expect_success("""
org &4000
MY_CONST equ &FF
ld a, MY_CONST
""", expected_min_bytes=2)

    def test_let_variable(self):
        """LET variables should work."""
        self._assemble_and_expect_success("""
org &4000
let X = 10
let Y = X + 5
db X, Y
""", expected_min_bytes=2)

    def test_conditional_assembly(self):
        """IF/ELSE/ENDIF should work."""
        self._assemble_and_expect_success("""
org &4000
let ASSEMBLE = 0
IF ASSEMBLE
    db &11
ELSE
    db &22
ENDIF
""", expected_min_bytes=1)

    def test_conditional_else_true(self):
        """IF with true ELSE branch should work."""
        self._assemble_and_expect_success("""
org &4000
let ASSEMBLE = 1
IF ASSEMBLE
    db &11
ELSE
    db &22
ENDIF
""", expected_min_bytes=1)

    def test_repeat_loop(self):
        """REPEAT/REND should work."""
        self._assemble_and_expect_success("""
org &4000
repeat 10
    db 0
rend
""", expected_min_bytes=10)

    def test_while_loop(self):
        """WHILE/WEND should work."""
        self._assemble_and_expect_success("""
org &4000
let COUNTER = 5
while COUNTER > 0
    db COUNTER
    let COUNTER = COUNTER - 1
wend
""", expected_min_bytes=5)

    def test_macro_definition(self):
        """MACRO/ENDM should work."""
        self._assemble_and_expect_success("""
org &4000
macro CLEAR_A
    ld a, 0
endm
CLEAR_A
""", expected_min_bytes=2)

    def test_macro_with_args(self):
        """MACRO with arguments should work."""
        self._assemble_and_expect_success("""
org &4000
macro LD_A_VAL, val
    ld a, val
endm
LD_A_VAL, 42
""", expected_min_bytes=2)

    def test_org_directive(self):
        """ORG directive should change position."""
        self._assemble_and_expect_success("""
org &5000
db 0x42
""", expected_min_bytes=1)

    def test_align_directive(self):
        """ALIGN directive should pad correctly."""
        self._assemble_and_expect_success("""
org &4000
db 0x01
align 4, 0x00
db 0x02
""", expected_min_bytes=4)

    def test_assert_true(self):
        """Assert that passes should not fail."""
        self._assemble_and_expect_success("""
org &4000
assert @ == &4000
db 0x01
""")

    def test_assert_false(self):
        """Assert that fails should abort assembly."""
        self._assemble_and_expect_error("""
org &4000
assert @ == &FFFF
""")

    def test_db_directives(self):
        """Various byte directives should work."""
        self._assemble_and_expect_success("""
org &4000
db &FF
defb &00, &01
""", expected_min_bytes=3)

    def test_dw_directives(self):
        """Word directives should produce 2 bytes each."""
        self._assemble_and_expect_success("""
org &4000
dw 0x1234
defw 0x5678
""", expected_min_bytes=4)

    def test_defs_directives(self):
        """RESERVE directives should work."""
        self._assemble_and_expect_success("""
org &4000
defs 10
ds 10
rmem 10
""", expected_min_bytes=30)

    def test_string_in_db(self):
        """String in db directive should work."""
        self._assemble_and_expect_success("""
org &4000
db "AB"
""", expected_min_bytes=2)

    def test_char_arithmetic(self):
        """Character + value should work."""
        self._assemble_and_expect_success("""
org &4000
db "A" + &80
""", expected_min_bytes=1)

    def test_hl_memory_access(self):
        """(HL) memory access should work."""
        self._assemble_and_expect_success("""
org &4000
ld a, (hl)
ld (hl), a
""", expected_min_bytes=2)

    def test_ix_indexed(self):
        """IX indexed access should work."""
        self._assemble_and_expect_success("""
org &4000
ld a, (ix+0)
ld (iy+1), a
""", expected_min_bytes=3)

    def test_cc_flags(self):
        """Conditional jumps should work."""
        self._assemble_and_expect_success("""
org &4000
jp z, here
jp nz, there
jr c, skip
ret m
here:
there:
skip:
    ret
""", expected_min_bytes=5)

    def test_rst_instructions(self):
        """RST instructions should work."""
        self._assemble_and_expect_success("""
org &4000
rst &00
rst &08
rst &10
rst &18
rst &20
rst &28
rst &30
rst &38
""", expected_min_bytes=8)

    def test_cb_prefix_instructions(self):
        """CB prefix instructions should work."""
        self._assemble_and_expect_success("""
org &4000
rlca
rrca
rla
rra
sla a
sra a
sll a
srl a
""", expected_min_bytes=8)

    def test_bit_set_res(self):
        """BIT/SET/RES instructions should work."""
        self._assemble_and_expect_success("""
org &4000
bit 0, a
set 7, b
res 3, c
""", expected_min_bytes=3)

    def test_push_pop(self):
        """PUSH/POP instructions should work."""
        self._assemble_and_expect_success("""
org &4000
push bc
pop de
push af
pop hl
""", expected_min_bytes=4)

    def test_exchange_instructions(self):
        """EXX/EX/EXAF instructions should work."""
        self._assemble_and_expect_success("""
org &4000
exx
ex af, af'
ex (sp), hl
""", expected_min_bytes=3)

    def test_di_ei_halt(self):
        """DI/EI/HALT/NOP should work."""
        self._assemble_and_expect_success("""
org &4000
di
ei
halt
nop
""", expected_min_bytes=4)

    def test_cpl_sccf(self):
        """CPL/SCF/CCF should work."""
        self._assemble_and_expect_success("""
org &4000
cpl
scf
ccf
""", expected_min_bytes=3)

    def test_im_and(self):
        """IM/AND/OR/XOR/NOT should work."""
        self._assemble_and_expect_success("""
org &4000
im 0
im 1
im 2
and a
or a
xor a
not
""", expected_min_bytes=7)

    def test_neg(self):
        """NEG instruction should work."""
        self._assemble_and_expect_success("""
org &4000
neg
""", expected_min_bytes=1)


class AsmPredefTestCase(unittest.TestCase):
    """Test pre-defined symbols passed via -d option."""

    @classmethod
    def setUpClass(cls):
        abasm.create_opdict()

    def _write_asm(self, content):
        tmp = os.path.join(tempfile.gettempdir(), str(uuid.uuid4()) + '.asm')
        with open(tmp, 'w') as f:
            f.write(content)
        return tmp

    def test_predefined_symbol(self):
        """Predefined symbol should be available."""
        tmp = self._write_asm("""
org &4000
db MY_VAL
""")
        out = tmp.replace('.asm', '.bin')
        try:
            abasm.assemble(tmp, out, [["MY_VAL", "42"]], 0x4000)
            with open(out, 'rb') as f:
                data = f.read()
            self.assertEqual(data[0], 42)
        finally:
            os.unlink(tmp)
            os.unlink(out)

    def test_predefined_hex(self):
        """Predefined symbol with hex value should work."""
        tmp = self._write_asm("""
org &4000
dw ADDR
""")
        out = tmp.replace('.asm', '.bin')
        try:
            abasm.assemble(tmp, out, [["ADDR", "0x5000"]], 0x4000)
            with open(out, 'rb') as f:
                data = f.read()
            self.assertEqual(data[0], 0x00)
            self.assertEqual(data[1], 0x50)
        finally:
            os.unlink(tmp)
            os.unlink(out)


if __name__ == "__main__":
    unittest.main()
