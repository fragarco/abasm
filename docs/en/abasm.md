- [Introduction](#introduction)
  - [Why Another Assembler for Amstrad?](#why-another-assembler-for-amstrad)
- [Basic Usage](#basic-usage)
  - [Available Options](#available-options)
  - [\*\*Usage Examples](#usage-examples)
- [Assembly Output](#assembly-output)
  - [The Binary File](#the-binary-file)
  - [Program Listing](#program-listing)
  - [Symbol File](#symbol-file)
- [Syntax](#syntax)
  - [Comments](#comments)
  - [Labels](#labels)
  - [Instructions](#instructions)
  - [Assembler Directives](#assembler-directives)
    - [ALIGN](#align)
    - [ASSERT](#assert)
    - [DB, DM, DEFB, DEFM](#db-dm-defb-defm)
    - [DS, DEFS, RMEM](#ds-defs-rmem)
    - [DW, DEFW](#dw-defw)
    - [EQU](#equ)
    - [IF](#if)
    - [INCBIN](#incbin)
    - [MACRO](#macro)
    - [LIMIT](#limit)
    - [LET](#let)
    - [READ](#read)
    - [REPEAT](#repeat)
    - [ORG](#org)
    - [PRINT](#print)
    - [SAVE](#save)
    - [STOP](#stop)
    - [WHILE](#while)
  - [Expressions and Special Characters](#expressions-and-special-characters)
- [The Z80 instruction set](#the-z80-instruction-set)
- [Changelog](#changelog)

# Introduction

ABASM is a cross-assembler specifically designed for the Amstrad CPC platform and its Z80 CPU. Developed in Python 3, its main goal is to provide a lightweight and highly portable tool for programmers interested in writing assembly code for this classic 8-bit platform. With no external libraries or third-party tools required, ABASM can run on any system with a Python 3 interpreter. Additionally, the project includes other tools, also written in Python and with no dependencies, to package the assembler’s output into DSK or CDT files.

ABASM is based on the fantastic pyZ80 project, initially created by Andrew Collier and later modified by Simon Owen.

## Why Another Assembler for Amstrad?

ABASM was conceived from the idea of having a portable tool that is easy to modify by anyone, without relying on specific operating systems or development environments. One of its goals is to provide a syntax compatible with the old MAXAM assembler, WinAPE syntax, and Virtual Machine Simulator. This gives developers several options to debug their code during development.

However, if you're looking for efficiency rather than portability and ease of modification, you may want to try the following assemblers:

* [Pasmo](https://pasmo.speccy.org/)
* [ASZ80](https://shop-pdp.net/ashtml/)
* [Rasm](https://github.com/EdouardBERGE/rasm)

# Basic Usage

To assemble a source file written in assembly language (e.g., `program.asm`), simply run the following command:

```
python3 abasm.py <program.asm> [options]
```

This command will assemble the `program.asm` file and generate a binary file with the same name, `program.bin`.

## Available Options

- `-d` or `--define`: Allows defining `SYMBOL=VALUE` pairs. These symbols can be used in the code as constants or labels. This option can be used multiple times to define several symbols.
- `--start`: Defines the memory address that will be used as the starting point for loading the program. By default, this address is `0x4000`, but it can also be set directly in the code using the `ORG` directive.
- `-o` or `--output`: Specifies the name of the output binary file. If this option is not used, the name of the input file will be used, with its extension changed to `.bin`.
- `v` or `--output`: Shows program's version and exits.
- `--verbose`: Prints more information in the console as the assemble progresses.
  
## **Usage Examples

Define a constant used in the code:

```
python3 abasm.py program.asm -d MY_CONSTANT=100
```

Set the exact name of the assembled binary file:

```
python3 abasm.py program.asm -o output.bin
```

Set the starting memory address for calculating jumps and other relative references in the source code, for example to `0x2000`:

```
python3 abasm.py program.asm --start 0x2000
```

# Assembly Output

A successful execution of ABASM generates several files. This section provides a brief explanation of each of these outputs.

## The Binary File

The final product of the assembly process is a binary file (usually with the `.BIN` extension) that is ready to be loaded into memory and executed on an Amstrad CPC. The source code can be divided into multiple files, but only one—the main file—is passed as a parameter to ABASM to start the assembly process. Additional files are included as they are referenced by the `READ` or `INCBIN` directives.

ABASM does not generate relocatable code, meaning it assumes a fixed starting memory address. This load address can be specified as a parameter when calling ABASM or set within the main file using the `ORG` directive.

For example, the following assembly code, which loads the value `0xFF` into the first position of the video memory, would generate the binary content shown below (in hexadecimal).

```
org  0x4000       ; Set the initial memory load address

main:
    ld   a,0xFF       ; Load the value 0xFF into the accumulator
    ld   (0xC000),a   ; Load the content of A into the first byte 
                      ; of video memory
endloop:              ; Infinite loop
    jp endloop        ; The value of 'endloop' is calculated 
                      ; based on the starting address set by ORG
```

```
3E FF 32 00 C0 C3 05 40
```

Since the Z80 is *little-endian*, we can see that the last three bytes are `C3 05 40`, which corresponds to `C3 4005`—the machine code for `jp endloop`, with `endloop` calculated from the starting address `0x4000`.

## Program Listing

For the programmer’s reference, the assembly process also generates a file containing a listing of the original program along with the binary result of each instruction. This file has the `.LST` extension.

Continuing with the previous example, the generated `.LST` file would contain the following:

```
main.asm      000001  4000               	org  0x4000
main.asm      000002  4000               	main
main.asm      000003  4000  3E FF        	ld   a, 0xFF
main.asm      000004  4002  32 00 C0     	ld  (0xC000), a
main.asm      000005  4005               	endloop
main.asm      000006  4005  C3 05 40     	jp endloop
```

The first column indicates the source archive. The second column shows the sequential line number in the source code. The third column indicates the memory location where the generated code was placed (if any, since some directives and labels do not generate binary code). The fourth column displays the binary code produced by assembling the instruction, and the last column shows the original instruction.

## Symbol File

ABASM also generates a listing of all symbols and their associated values. Most of these will be labels used to mark jump points or memory locations where certain data has been stored.

The extension of this file is `.MAP`, and it is formatted as a Python dictionary. This allows the file to be used by other utilities (such as DSK and CDT packagers) and to reference the symbols rather than their actual values. An example of using this file can be found in the documentation for DSK and CDT utilities.

```
# List of symbols in Python dictionary format
# Symbol: [address, total number of reads (uses), file name]
{
	"ENDLOOP": [0x4005, 2, "MAIN.ASM"],
	"MAIN": [0x4000, 1, "MAIN.ASM"],
}
```

# Syntax

ABASM's syntax is designed to closely resemble that of the MAXAM assembler. This syntax is quite compatible with that supported by the WinAPE emulator. Additionally, ABASM supports some variations that also make it compatible with the syntax used by the Retro Virtual Machine emulator. The goal is to provide developers using ABASM with several tools for debugging and testing their programs.

Below is a simple example of a program written using ABASM syntax. This example demonstrates three of the basic elements of any assembly language program: labels, instructions, and comments. A fourth element would be assembler directives, commands directed at ABASM itself rather than at the Z80 processor. In this chapter, we will also review the complete list of supported directives.

An important aspect of all four elements is that ABASM is case-insensitive. Therefore, 'LD A,32' and 'ld a,32' produce the same result. The same applies to labels: 'main', 'MAIN', or 'Main' are considered the same label.

```
; Prints all ASCII characters between code 32 and 128.
; It's a variation of the first example presented in the
; MAXAM manual

main              ; defines the global label 'main'
    ld a,32       ; first ASCII letter code in accumulator

.loop             ; defines the local label 'loop'
    call &BB5A    ; CALL txt_output, the firmware output routine
    inc  a        ; move to next character
    cp   128      ; have we done them all?
    jr   c,.loop  ; no - go back for another one

.end  
    jp   .end     ; infinite loop used as the program's end point

```

Another important aspect is that ABASM reserves the character '.' at the beginning of any label to designate local labels, which will only be accesible from within the source file where they got declared.

## Comments

Comments in assembly code are annotations written by the programmer that are not interpreted or executed by the CPU. Their purpose is to provide additional information about the code, making it more understandable and maintainable.

Comments are important in any programming language, but in assembly, they are even more crucial due to the low level of abstraction of the language. This makes the code harder to interpret. Therefore, comments are essential for explaining the purpose and functionality of the code. As a general rule, it is recommended to use comments to:

- Describe complex parts of the code, explaining what a particular sequence of instructions does or the parameters and return value of a subroutine.
- Delimit sections of the code, such as loops, functions, or logical blocks.
- Provide context, indicating the purpose of a variable, label, or constant.

In ABASM, comments are usually indicated with the character ';' (semicolon). When ABASM encounters this character, it ignores the rest of the line.

```
; This is a comment
; This is another comment
```

## Labels

Labels in assembly code are symbolic names used to mark a specific position in the program, such as a memory address or an instruction. Their main uses include:

- In jumps and loops: Labels are used as targets in jump instructions (JMP, JE, etc.), allowing the flow of execution to be redirected to a specific part of the program.

- In data definitions: Labels are used to refer to variables or data in memory, making them easier to access and manipulate.

- As entry points to code blocks: Labels help make the code more readable and maintainable by providing descriptive names to important sections of the program.

All labels are **global** by default, meaning they must be unique regardless of how many files the source code is divided into. ABASM ignores the leading '.' in label definitions to support the WinApe label declaration format.  

To create a local label (restricted to a module/file or within a macro), the label must start with the symbol '!'. If the label is defined outside a macro, it is considered a **module-local label**, accessible only within the file where it is declared. This also prevents the label from appearing in the Symbol File.  

If the label is defined inside a macro, it is treated as a **macro-local label**. Macro-local labels are essential to prevent errors caused by label redefinitions when the macro is invoked multiple times.

```
!loop
  <some other code>
  dec b
  jr z,!loop
```

## Instructions

Instructions are operations that the CPU (the Z80 processor in our case) must perform. The process of assembling involves generating the corresponding binary code for these instructions. Each instruction typically consists of an *opcode* and its *operands*.

An opcode (short for operation code) is the part of an instruction that specifies the action the CPU must perform. It is a unique binary or hexadecimal value associated with a particular operation, such as adding, subtracting, loading a value into a register, or performing a comparison. Thus, the opcode determines the operation to execute, while the operands (if any) provide the data needed for that operation. For example:

```
ld a,32
```

The *opcode* (or its nemotecnic more precisely) would be 'ld a', while the operand would be '32'. The meaning of the opcode is 'load into register A', and the value to load is the number 32.

ABASM supports all standard Z80 instructions. To enhance compatibility with WinAPE syntax, instructions like AND, CP, OR, and SUB accept adding the A register as part of the *opcode*. However, the shorter form without the explicit A is preferred, and a warning will be issued if the extended format is encountered (e.g., `CP A, &0A` is equivalent to `CP &0A` but will issue a warning if found).

Regarding operands, ABASM fully supports all standard Z80 8-bit registers: A, B, C, D, E, H, and L, as well as the special 8-bit registers I and R. It also supports all standard Z80 16-bit registers: AF, BC, DE, HL, and SP, along with the index registers IX and IY. Additionally, ABASM provides support for the undocumented use of the 8-bit portions of the IX and IY registers, allowing for IXL, IXH, IYL, and IYH. The alternate AF' register is also supported for use in appropriate instructions, such as in the `EX AF, AF'` command.

Lastly, ABASM supports all standard Z80 condition flags: NZ, Z, NC, C, PO, PE, P, and M.

To learn more about each instruction, a short list can be consulted in the `Z80 Instruction Set`, later on this same document. However, the following list of helpful reference sources can be visited to gain a more deep knowledge:

- [@ClrHome Z80 Table of Instructions](https://clrhome.org/table/): A well-organized table that provides a concise summary of all Z80 instructions.
- [Zilog's Official Documentation for the Z80 Processor](https://www.zilog.com/docs/z80/um0080.pdf): Especially useful are the last two sections titled *Z80 CPU Instructions* and *Z80 Instruction Set*.
- [Z80 Heaven](http://z80-heaven.wikidot.com/): A web with a detailed information for each instruction.

## Assembler Directives

An assembler directive is an instruction that does not directly translate into machine code for the CPU but provides information or instructions to the assembler on how to process the source code. These directives control aspects of the assembly process, such as code organization, data definition, memory allocation, and constant definitions. Unlike instructions executed by the CPU, directives only affect the assembler during the assembly of the source code. Common examples include ORG (to set the starting address), EQU (to define constants), and DB (to define data in memory). The complete list of directives supported by ABASM and their meanings are as follows:

### ALIGN

- ALIGN n [,v]

*n* must be a number or numerical expression that is a power of two. This directive adds the necessary bytes so that the memory used up to that point by the program is a multiple of *n*. The optional second parameter sets the value used to fill the required memory (a value between 0 and 255). If this second argument is not specified, the memory is filled with zeros.

For example:

```
main:
    LD A, 0xFF
    ALIGN 8
data:
    DB 0xAA, 0xBB, 0xCC
```

This will produce the following binary code:

```
3E FF 00 00 00 00 00 00 AA BB CC
```

### ASSERT

- ASSERT condition

This directive evaluates whether the provided condition is met. If not, it aborts the assembly process. For example, the following code checks that the next instruction to be assembled does not occupy a memory position higher than the start of video memory (0xC000 on the Amstrad CPC).

```
ASSERT @<0xC000
```

### DB, DM, DEFB, DEFM 

- DEFB  n [,n ...]
- DEFM  n [,n ...]
- DB    n [,n ...]
- DM    n [,n ...]

Stores the provided list of bytes at the current memory location. *n* can be a number or a numerical expression in the range of 0 to 255 (0x00 to 0xFF).

```
DB 0xFF, 0xFF, 0xFF, 0xFF
```

You can also use a text string as a parameter and combine it with the above format. In this case, the ASCII codes of each letter will be stored as if they were the provided numeric values.

```
DB "Hello World",0x00
```

### DS, DEFS, RMEM

- DEFS  n
- DS    n
- RMEM  n

Reserves *n* bytes of memory. Essentially, the current memory position is incremented by *n* bytes, leaving it free for later use.

### DW, DEFW

- DEFW  n [,n ...]
- DW    n [,n ...]

Stores *words* (two bytes in little-endian format) at the current memory location. *n* can be a number or a numerical expression in the range of 0 to 65535 (0x0000 to 0xFFFF).

```
year:
    DW  2024
```

### EQU

- EQU symbol, value
- symbol EQU value

Sets the value of a symbol, typically used as a constant.

```
EQU MEM_VIDEO, 0xC000

LD  A,0xFF
LD  (MEM_VIDEO),A
```

### IF

- IF condition [ELSEIF condition | ELSE] ENDIF

The IF directive allows certain parts of the code to be included or ignored depending on the value of a logical expression. This expression can contain symbols and numerical values. If the expression is true (non-zero), the assembler will process the lines following the IF directive. If it is false (zero), those lines will be ignored.

A basic IF structure could be:

```
IF expression
    ; Assembled code if the expression is true
ELSE
    ; Assembled code if the expression is false
ENDIF
```

This directive is useful when combined with ABASM's `--define` option, which allows changing what code is assembled depending on the call made to the assembler. However, any symbol or constant referenced in the logical expression must have been declared beforehand.

### INCBIN

- INCBIN "binary file"

This directive inserts the contents of the file specified in double quotes. The file path should be relative to the location of the file that includes it.

```
INCBIN "./assets/mysprite.bin"
```

### MACRO

- MACRO symbol [param1, param2, ...] ENDM

This directive allows you to assign a name or symbol to a block of code, which extends until the next occurrence of ENDM. The macro can take a list of parameters, which will be replaced by the corresponding values provided in the  *calls* to the macro. Once defined, a macro can be used throughout the rest of the code just like a regular instruction. Each parameter passed is substituted literally into the code inside the macro when it is encountered as a whole word. For that reason, start and finish each parameter name with the character '_' may be a good practice to avoid matches with text strings or register names.

```
macro get_screenPtr _REG_, _X_, _Y_ 
   ld _REG_, &C000 + 80 * (_Y_ / 8) + 2048 * (_Y_ & 7) + _X_ 
endm

main:
   get_screenPtr hl, 20, 10
``` 

Macro code can contain *calls* to other macros but it's not possible to define a new macro or use the directive **read**. If a macro contains a regular label and the macro is *called* more than once, the assembler will detect a symbol redefinition, which will cause an error. For that reason, If a macro needs to use labels, they must be preceded by the symbol '!' which singnales them as **macro local labels**.

```
macro decnz_a
  or a
  jr z,!leave
  dec a
  !leave
mend
```

WinApe uses the symbol '@' to mark **macro local labels** but that symbol is used by ABASM to represent the current instruction's memory address too. As a result, ABASM departs from WinApe in this point.

### LIMIT

- LIMIT memory_address

Sets the maximum memory address that the assembled program can reach. The provided value can be either a number or a numerical expression. By default, this value is set to 65,536 (64K).

```
LIMIT &C000   ; no code can be written inside the video memory which starts at &C000
ORG &C000
LD A, &FF     ; this line will cause an error
```

### LET

- LET symbol=value

This directive allows changing the value of a symbol or constant. This symbol or constant must have been initially defined with LET.

```
LET PADDING=0x00
<code>
LET PADDING=0xFF
<more code>
```

### READ

- READ "source code file"

This directive inserts the contents of the file specified in double quotes and assembles it. The file path should be relative to the location of the file that includes it. All symbols defined in the inserted file are global, so they must be unique and not repeated in the main file or any other file included using this method.

```
READ "./lib/keyboard.asm"
```

### REPEAT

- REPEAT numeric expression `code block` REND

Repeats a block of code as many times as the value specified by the numeric expression.

```
EQU ENTITIES, 10
LET ENTITY_ID = 0
REPEAT ENTITIES
  DB 0x00       ; X pos
  DB 0x00       ; Y pos
  DB ENTITY_ID  ; Entity ID
  LET ENTITY_ID = ENTITY_ID + 1
REND
```

### ORG

- ORG memory_address

Specifies the memory address to be considered as the current address from that point forward for any necessary calculations, such as setting the value of a label. Typically, if this directive is used, it appears as the first instruction of the source code, although it's possible to replace it with the ABASM's command line parameter `--start`.

```
ORG 0x4000
```

There is nothing to prevent the source code from including more than one occurrence of this directive, although it is not recommended, as the resulting binary file will fill with 0s any remaining empty memory between the starting memory position for the program and the highest memory written address. This will increase the final `bin` file size. Therefore, if a program needs to have parts loaded in different memory areas, it is advisable to generate a separate binary file for each area and package them all within the same DSK or CDT, along with a loader programmed in BASIC (for example).

### PRINT

- PRINT expression[, expression ...]

Prints the result of the provided expression(s) to the standard output as soon as it is evaluated during assembly. This can be useful for generating additional information during assembly, such as the total memory consumed by the program.

```
ORG 0x4000
<code>
PRINT @-0x4000
```

### SAVE

- SAVE "filename", numeric expression, numeric expression

This directive allows the generation of additional binary files containing the memory where the assembled code is being written. The memory has a maximum size of 64K, which is the limit of the Amstrad CPC 464. The first expression defines the starting address, while the second specifies the total number of bytes to be written to the file.

```
SAVE "myscreen.bin",&C000,&4000
```

### STOP

- STOP

Stops the assembly process issuing an error.

### WHILE

- WHILE logic expression `code block` WEND

It allows a block of code to be assembled repeatedly as long as the specified condition is met. If the condition never becomes false, this directive can result in an infinite loop.

```
LET OBJECTS = 32
WHILE OBJECTS>0
  db 0
  db 0
  db 0
  LET OBJECTS = OBJECTS-1
WEND
```

## Expressions and Special Characters

When an instruction or directive requires a number as a parameter, you can use a mathematical expression instead. These expressions can reference any symbol defined in the code. If the result of an expression is negative, its two's complement is used as the value. Additionally, some symbols have special meanings, as outlined in the following list:

- **$** represents the current instruction's memory address.
- **@** is interchangeable with the **$** symbol.
- **&** prefix indicates hexadecimal numbers (e.g., &FF).
- **0x** prefix indicates hexadecimal numbers (e.g., 0xFF).
- **%** prefix indicates binary numbers (e.g., %11111111).
- **0b** prefix indicates binary numbers (e.g., 0b11111111).
- **"** double quotes delimit characters or strings (1).
- **'** single quotes are equivalent to double quotes for delimiting strings.
- **MOD** represents the modulo operator.
- **AND** represents de bitwise AND operator: op1 AND op2. The Python operator & can be used too.
- **OR** represents de bitwise OR operator: op1 AND op2. The Python operator | can be used too.
- **XOR** represents de bitwise XOR operator: op1 AND op2. The Python operator ^ can be used too.
- **<<** represents the shift left operator.
- **>>** represents the shift right operator.
  
(1) A single character enclosed in double quotes will be converted to its ASCII value in numerical expressions. Double and single quotes can be used to enclose strings but neither can appear in the string body.

# The Z80 instruction set

This section provides a short list of all Z80 available instructions. While many resources list instruction timing in cycles or T-states, the Amstrad CPC has its own timing due to the Gate Array pausing the Z80 to access video memory. Therefore, it's more accurate to measure timing on the Amstrad CPC based on the cost of the NOP instruction (1 microsecond).

- [Z80 Timings on Amstrad CPC - Cheat Sheet](https://www.cpcwiki.eu/imgs/b/b4/Z80_CPC_Timings_cheat_sheet.20230709.pdf): This document is invaluable for understanding the real timing cost of all Z80 instructions.

**Key:**
```
r 	8-bit register (B,C,D,E,H,L,A)
n 	8-bit value
d 	8-bit displacement

rr 	16-bit register (HL,DE,BC)
nn 	16-bit value
dd  16-bit displacement

cc	condition code (z,nz,c,nc,p,m,po,pe)
nc 	condition not satisfied
c 	condition satisfied

b   bit position number [7-0]
```

```
opcode    timing    explanation

ADC   A,r       1 Add with carry register r to accumulator.
ADC   A,n       2 Add with carry value n to accumulator.
ADC   A,IXH     2 Add with carry high byte from IX to accumulator.
ADC   A,IXL     2 Add with carry low byte from IX to accumulator.
ADC   A,IYH     2 Add with carry high byte from IY to accumulator.
ADC   A,IYL     2 Add with carry low byte from IY to accumulator.
ADC   A,(HL)    2 Add with carry location (HL) to acccumulator.
ADC   A,(IX+d)  5 Add with carry location (IX+d) to accumulator.
ADC   A,(IY+d)  5 Add with carry location (IY+d) to accumulator.

ADC   HL,BC     4 Add with carry register pair BC to HL.
ADC   HL,DE     4 Add with carry register pair DE to HL.
ADC   HL,HL     4 Add with carry register pair HL to HL.
ADC   HL,SP     4 Add with carry register pair SP to HL.

ADD   A,r       1 Add register r to accumulator.
ADD   A,n       2 Add value n to accumulator.
ADC   A,IXH     2 Add high byte from IX to accumulator.
ADC   A,IXL     2 Add low byte from IX to accumulator.
ADC   A,IYH     2 Add high byte from IY to accumulator.
ADC   A,IYL     2 Add low byte from IY to accumulator.
ADD   A,(HL)    2 Add location (HL) to acccumulator.
ADD   A,(IX+d)  5 Add location (IX+d) to accumulator.
ADD   A,(IY+d)  5 Add location (IY+d) to accumulator.

ADD   HL,BC     3 Add register pair BC to HL.
ADD   HL,DE     3 Add register pair DE to HL.
ADD   HL,HL     3 Add register pair HL to HL.
ADD   HL,SP     3 Add register pair SP to HL.

ADD   IX,BC     4 Add register pair BC to IX.
ADD   IX,DE     4 Add register pair DE to IX.
ADD   IX,IX     4 Add register pair IX to IX.
ADD   IX,SP     4 Add register pair SP to IX.

ADD   IY,BC     4 Add register pair BC to IY.
ADD   IY,DE     4 Add register pair DE to IY.
ADD   IY,IY     4 Add register pair IY to IY.
ADD   IY,SP     4 Add register pair SP to IY.

AND   r         1 Logical AND of register r to accumulator.
AND   n         2 Logical AND of value n to accumulator.
AND   IXH       2 Logical AND of IX high byte to accumulator.
AND   IXL       2 Logical AND of IX low byte to accumulator.
AND   IYH       2 Logical AND of IY high byte to accumulator.
AND   IYL       2 Logical AND of IY low byte to accumulator.
AND   (HL)      2 Logical AND of value at location (HL) to accumulator.
AND   (IX+d)    5 Logical AND of value at location (IX+d) to accumulator.
AND   (IY+d)    5 Logical AND of value at location (IY+d) to accumulator.

BIT   b,r       2 Test bit b of register r.
BIT   b,(HL)    3 Test bit b of location (HL).
BIT   b,(IX+d)  6 Test bit b of location (IX+d).
BIT   b,(IY+d)  6 Test bit b of location (IY+d).

CALL  nn        5 Call subroutine at location.
CALL  cc,nn   3/5 Call subroutine at location nn if condition CC is true (5) else (3).

CCF             1 Complement carry flag.

CP    r         1 Compare register r with accumulator.
CP    n         2 Compare value n with accumulator.
CP    IXH       1 Compare IX high byte with accumulator.
CP    IXL       1 Compare IX low byte with accumulator.
CP    IYH       1 Compare IY high byte with accumulator.
CP    IYL       1 Compare IY low byte with accumulator.
CP    (HL)      2 Compare value at location (HL) with accumulator.
CP    (IX+d)    5 Compare value at location (IX+d) with accumulator.
CP    (IY+d)    5 Compare value at location (IY+d) with accumulator.

CPD             5 Compare location (HL) and acc., decrement HL and BC,
CPDR          5/6 Perform a CPD and repeat until BC=0 (5), if BC<>0 (6).
CPI             5 Compare location (HL) and acc., incr HL, decr BC.
CPIR          5/6 Perform a CPI and repeat until BC=0 (5), if BC<>0 (6).
CPL             1 Complement accumulator (1's complement).

DAA             1 Decimal adjust accumulator.

DEC   r         1 Decrement register r.
DEC   IXH       2 Decrement IX high byte.
DEC   IXL       2 Decrement IX low byte.
DEC   IYH       2 Decrement IY high byte.
DEC   IYL       2 Decrement IY low byte.
DEC   (HL)      3 Decrement value at location (HL).
DEC   (IX+d)    6 Decrement value at location (IX+d).
DEC   (IY+d)    6 Decrement value at location (IY+d).

DEC   BC        2 Decrement register pair BC.
DEC   DE        2 Decrement register pair DE.
DEC   HL        2 Decrement register pair HL.
DEC   IX        3 Decrement IX.
DEC   IY        3 Decrement IY.
DEC   SP        2 Decrement register pair SP.

DI              1 Disable interrupts. (except NMI at 0066h)

DJNZ  n       3/4 Decrement B and jump relative if B<>0 (4) else (3).

EI              1 Enable interrupts.

EX    AF,AF'    1 Exchange the contents of AF and AF'.
EX    DE,HL     1 Exchange the contents of DE and HL.
EX    (SP),HL   6 Exchange the location (SP) and HL.
EX    (SP),IX   7 Exchange the location (SP) and IX.
EX    (SP),IY   7 Exchange the location (SP) and IY.
EXX             1 Exchange the contents of BC,DE,HL with BC',DE',HL'.

HALT          1/* Halt computer and wait for interrupt (variable timing).

IM    0         2 Set interrupt mode 0. (instruction on data bus by int device)
IM    1         2 Set interrupt mode 1. (rst 38)
IM    2         2 Set interrupt mode 2. (vector jump)

IN    A,(n)     3 Load the accumulator with input from device/port n.
IN    r,(C)     4 Load the register r with input from device/port stored in B(!!)[1].

INC   r         1 Increment register r.
INC   IXH       2 Increment IX high byte.
INC   IXL       2 Increment IX low byte.
INC   IYH       2 Increment IY high byte.
INC   IYL       2 Increment IY low byte.
INC   (HL)      3 Increment location (HL).
INC   (IX+d)    6 Increment location (IX+d).
INC   (IY+d)    6 Increment location (IY+d).

INC   BC        2 Increment register pair BC.
INC   DE        2 Increment register pair DE.
INC   HL        2 Increment register pair HL.
INC   IX        3 Increment IX.
INC   IY        3 Increment IY.
INC   SP        2 Increment register pair SP.

IND             5 (HL)=Input from port (C), Decrement HL and B.
INDR          5/6 Perform an IND and repeat until B=0 (5), if B<>0 (6).
INI             5 (HL)=Input from port (C), HL=HL+1, B=B-1.
INIR          5/6 Perform an INI and repeat until B=0 (5), if B<>0 (6).

JP    nn        3 Unconditional jump to location nn.
JP    cc,nn     3 Jump to location nn if condition cc is true.
JP    (HL)      1 Unconditional jump to location (HL).
JP    (IX)      2 Unconditional jump to location (IX).
JP    (IY)      2 Unconditional jump to location (IY).

JR    c,n     2/3 Jump relative to PC+n if carry=1 (3) else (2).
JR    n         3 Unconditional jump relative to PC+n.
JR    nc,n    2/3 Jump relative to PC+n if carry=0 (3) else (2).
JR    nz,n    2/3 Jump relative to PC+n if non zero (3) else (2).
JR    z,n     2/3 Jump relative to PC+n if zero (3) else (2).

LD    A,R       3 Load accumulator with R.(memory refresh register)
LD    A,I       3 Load accumulator with I.(interrupt vector register)
LD    A,(BC)    2 Load accumulator with value at location (BC).
LD    A,(DE)    2 Load accumulator with value at location (DE).
LD    A,(nn)    4 Load accumulator with value at location nn.

LD    I,A       3 Load I with accumulator.
LD    R,A       3 Load R with accumulator.
LD    r,n       2 Load register r with value n.
LD    r,(HL)    2 Load register r with value at location (HL).
LD    r,(IX+d)  5 Load register r with value at location (IX+d).
LD    r,(IY+d)  5 Load register r with value at location (IY+d).

LD    SP,HL     2 Load SP with HL.
LD    SP,IX     3 Load SP with IX.
LD    SP,IY     3 Load SP with IY.

LD    BC,nn     3 Load register pair BC with nn.
LD    DE,nn     3 Load register pair DE with nn.
LD    HL,nn     3 Load register pair HL with nn.
LD    IX,nn     4 Load IX with value nn.
LD    IY,nn     4 Load IY with value nn.
LD    SP,nn     3 Load register pair SP with nn.
LD    BC,(nn)   6 Load register pair BC with value at location (nn).
LD    DE,(nn)   6 Load register pair DE with value at location (nn).
LD    HL,(nn)   5 Load HL with value at location (nn), L-first.
LD    IX,(nn)   6 Load IX with value at location (nn).
LD    IY,(nn)   6 Load IY with value at location (nn).
LD    SP,(nn)   6 Load register pair SP with value at location (nn).

LD    (BC),A    2 Load location (BC) with accumulator.
LD    (DE),A    2 Load location (DE) with accumulator.
LD    (HL),n    3 Load location (HL) with value n.
LD    (HL),r    2 Load location (HL) with register r.
LD    (IX+d),n  6 Load location (IX+d) with value n.
LD    (IX+d),r  5 Load location (IX+d) with register r.
LD    (IY+d),n  6 Load location (IY+d) with value n.
LD    (IY+d),r  5 Load location (IY+d) with register r.

LD    (nn),A    4 Load location (nn) with accumulator.
LD    (nn),BC   6 Load location (nn) with register pair BC.
LD    (nn),DE   6 Load location (nn) with register pair DE.
LD    (nn),HL   5 Load location (nn) with HL.
LD    (nn),SP   6 Load location (nn) with register pair SP.
LD    (nn),IX   6 Load location (nn) with IX.
LD    (nn),IY   6 Load location (nn) with IY.

LDD             5 Load location (DE) with location (HL), decrement DE,HL,BC.
LDDR          5/6 Perform an LDD and repeat until BC=0 (5) else (6).
LDI             5 Load location (DE) with location (HL), incr DE,HL; decr BC.
LDIR          5/6 Perform an LDI and repeat until BC=0 (5) else (6).

NEG             2 Negate accumulator (2's complement).
NOP             1 No operation.

OR    r         1 Logical OR of register r and accumulator.
OR    n         2 Logical OR of value n and accumulator.
OR    IXH       2 Logical OR of IX high byte and accumulator.
OR    IXL       2 Logical OR of IX low byte and accumulator.
OR    IYH       2 Logical OR of IY high byte and accumulator.
OR    IYL       2 Logical OR of IY low byte and accumulator.
OR    (HL)      2 Logical OR of value at location (HL) and accumulator.
OR    (IX+d)    5 Logical OR of value at location (IX+d) and accumulator.
OR    (IY+d)    5 Logical OR of value at location (IY+d) and accumulator.

OTDR          5/6 Perform an OUTD and repeat until B=0 (5) else (6)[1].
OTIR          5/6 Perform an OTI and repeat until B=0 (5) else (6)[1].
OUT   (C),r     4 Load output port stored in reg B(!!) with register r[1].
OUT   (n),A     3 Load output port (n) with accumulator[1].
OUTD            5 Load output port in reg B(!!) with (HL), decrement HL and B[1].
OUTI            5 Load output port in reg B(!!) with (HL), incr HL, decr B[1].

POP   AF        3 Load register pair AF with top of stack.
POP   BC        3 Load register pair BC with top of stack.
POP   DE        3 Load register pair DE with top of stack.
POP   HL        3 Load register pair HL with top of stack.
POP   IX        5 Load IX with top of stack.
POP   IY        5 Load IY with top of stack.
PUSH  AF        4 Load register pair AF onto stack.
PUSH  BC        4 Load register pair BC onto stack.
PUSH  DE        4 Load register pair DE onto stack.
PUSH  HL        4 Load register pair HL onto stack.
PUSH  IX        5 Load IX onto stack.
PUSH  IY        5 Load IY onto stack.

RES   b,r       2 Reset bit b of register r.
RES   b,(HL)    4 Reset bit b in value at location (HL).
RES   b,(IX+d)  7 Reset bit b in value at location (IX+d).
RES   b,(IY+d)  7 Reset bit b in value at location (IY+d).

RET             3 Return from subroutine.
RET   cc      2/4 Return from subroutine if condition cc is true (4) else (2).
RETI            4 Return from interrupt.
RETN            4 Return from non-maskable interrupt.

RL    r         2 Rotate left through register r.
RL    (HL)      4 Rotate left through value at location (HL).
RL    (IX+d)    7 Rotate left through value at location (IX+d).
RL    (IY+d)    7 Rotate left through value at location (IY+d).
RLA             4 Rotate left accumulator through carry.

RLC   r         2 Rotate register r left circular.
RLC   (HL)      4 Rotate location (HL) left circular.
RLC   (IX+d)    7 Rotate location (IX+d) left circular.
RLC   (IY+d)    7 Rotate location (IY+d) left circular.

RLCA            1 Rotate left circular accumulator.
RLD             5 Rotate digit left and right between accumulator and (HL).

RR    r         2 Rotate right through carry register r.
RR    (HL)      4 Rotate right through carry location (HL).
RR    (IX+d)    7 Rotate right through carry location (IX+d).
RR    (IY+d)    7 Rotate right through carry location (IY+d).

RRA             1 Rotate right accumulator through carry.

RRC   r         2 Rotate register r right circular.
RRC   (HL)      4 Rotate value at location (HL) right circular.
RRC   (IX+d)    7 Rotate value at location (IX+d) right circular.
RRC   (IY+d)    7 Rotate value at location (HL+d) right circular.

RRCA            1 Rotate right circular accumulator.
RRD             5 Rotate digit right and left between accumulator and (HL).

RST   &00       4 RESET. Reserved [2]. Resets the system.
RST   &08       4 LOW JUMP. Reserved [2]. Jumps to a routine in the lower 16K.
RST   &10       4 SIDE CALL. Reserved [2]. Calls a routine in an associated ROM.
RST   &18       4 FAR CALL. Reserved [2]. Calls a routine anywhere in memory.
RST   &20       4 RAM LAM. Reserved [2]. Reads the byte from RAM at the address of HL.
RST   &28       4 FIRM JUMP. Reserved [2]. Jumps to a routine in the lower ROM.
RST   &30       4 USER RST. Avaiable for the user to extend the instruction set.
RST   &38       4 INTERRUPT. Reserver [2]. Reserverd for interrupts.

SBC   A,r       1 Subtract register r from accumulator with carry.
SBC   A,n       2 Subtract value n from accumulator with carry.
ADC   A,IXH     2 Subtract IX high byte from accumulator with carry.
ADC   A,IXL     2 Subtract IX low byte from accumulator with carry.
ADC   A,IYH     2 Subtract IY high byte from accumulator with carry.
ADC   A,IYL     2 Subtract IY low byte from accumulator with carry.
SBC   A,(HL)    2 Subtract value at location (HL) from accu. with carry.
SBC   A,(IX+d)  5 Subtract value at location (IX+d) from accu. with carry.
SBC   A,(IY+d)  5 Subtract value at location (IY+d) from accu. with carry.
SBC   HL,BC     4 Subtract register pair BC from HL with carry.
SBC   HL,DE     4 Subtract register pair DE from HL with carry.
SBC   HL,HL     4 Subtract register pair HL from HL with carry.
SBC   HL,SP     4 Subtract register pair SP from HL with carry.

SCF             1 Set carry flag (C=1).

SET   b,r       2 Set bit b of register r.
SET   b,(HL)    4 Set bit b of location (HL).
SET   b,(IX+d)  7 Set bit b of location (IX+d).
SET   b,(IY+d)  7 Set bit b of location (IY+d).

SLA   r         2 Shift register r left arithmetic.
SLA   (HL)      4 Shift value at location (HL) left arithmetic.
SLA   (IX+d)    7 Shift value at location (IX+d) left arithmetic.
SLA   (IY+d)    7 Shift value at location (IY+d) left arithmetic.

SLL   r         2 Shift register r left logical.
SLL   (HL)      4 Shift value at location (HL) left logical.
SLL   (IX+d)    7 Shift value at location (IX+d) left logical.
SLL   (IY+d)    7 Shift value at location (IY+d) left logical.

SRA   r         2 Shift register r right arithmetic.
SRA   (HL)      4 Shift value at location (HL) right arithmetic.
SRA   (IX+d)    7 Shift value at location (IX+d) right arithmetic.
SRA   (IY+d)    7 Shift value at location (IY+d) right arithmetic.

SRL   r         2 Shift register r right logical.
SRL   (HL)      4 Shift value at location (HL) right logical.
SRL   (IX+d)    7 Shift value at location (IX+d) right logical.
SRL   (IY+d)    7 Shift value at location (IY+d) right logical.

SUB   r         1 Subtract register r from accumulator.
SUB   n         2 Subtract value n from accumulator.
SUB   IXH       2 Subtract IX high byte from accumulator.
SUB   IXL       2 Subtract IX low byte from accumulator.
SUB   IYH       2 Subtract IY high byte from accumulator.
SUB   IYL       2 Subtract IY low byte from accumulator.
SUB   (HL)      2 Subtract location (HL) from accumulator.
SUB   (IX+d)    5 Subtract location (IX+d) from accumulator.
SUB   (IY+d)    5 Subtract location (IY+d) from accumulator.

XOR   r         1 Exclusive OR register r and accumulator.
XOR   n         2 Exclusive OR value n and accumulator.
XOR   IXH       2 Exclusive OR IX high byte and accumulator.
XOR   IXL       2 Exclusive OR IX low byte and accumulator.
XOR   IYH       2 Exclusive OR IY high byte and accumulator.
XOR   IYL       2 Exclusive OR IY low byte and accumulator.
XOR   (HL)      2 Exclusive OR value at location (HL) and accumulator.
XOR   (IX+d)    5 Exclusive OR value at location (IX+d) and accumulator.
XOR   (IY+d)    5 Exclusive OR value at location (IY+d) and accumulator.
```

**[1]** It's important to remember that OUT/IN family instructions use `BC` content and not only C, even if the op code is `OUT (C)`. In Amstrad CPC, instructions OUTD, OUTI, OTIR, etc., don't make much sense because AMSTRAD CPC uses register `B`(!!) from the address in BC to store the port number and not `C` as many other Z80 machines do. 

**[2]** All the Z80 restart instructions, except for one, have been reserved for system use. RST 1 to RST 5 (&08-&28) are used to extend the instruction set by implementing special call and jump instructions that enable and disable ROMs. RST 6 (&30) is available to the user. More information can be obtained here: [ROMs. TAM and Restart Instructions.](https://www.cpcwiki.eu/imgs/f/f6/S968se02.pdf)

# Changelog

- Version 1.1.1 - ??/??/????
   * 

- Version 1.1.0 - 06/03/2025
  * Support for directive LIMIT
  * Support for local labels in macro code
  * New assembler flag --verbose added as an option
  * Adding Tests that can be run with python -m unittest
  * Some minor fixes and improvements

- Version 1.0.0 - 03/10/2024
  * First released version



