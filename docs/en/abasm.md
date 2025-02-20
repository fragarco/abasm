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

All labels are **global** by default, meaning they must be unique regardless of how many files the source code is divided into. To define **module local labels**, only accesible within the file where they are declared, they must start with the character '.'. This will prevent the label from appearing in the Symbol File too. However, neither WinAPE or Retro Virtual Machine emulators support the concept of local labels so the use of this feature could introduce incompativilities with the sintax supported by these emulators.

Finally, labels must start with the symbol '!' within a macro code because that signales them as **macro local labels** and avoids errors due to label redefinition if the macro is *called* more  than once.

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

To learn more about each instruction, the following list of helpful reference sources can be consulted:

- [@ClrHome Z80 Table of Instructions](https://clrhome.org/table/): A well-organized table that provides a concise summary of all Z80 instructions.
- [Zilog's Official Documentation for the Z80 Processor](https://www.zilog.com/docs/z80/um0080.pdf): Especially useful are the last two sections titled *Z80 CPU Instructions* and *Z80 Instruction Set*.
- [Z80 Heaven](http://z80-heaven.wikidot.com/): A web with a detailed information for each instruction.
- [Z80 Timings on Amstrad CPC - Cheat Sheet](https://www.cpcwiki.eu/imgs/b/b4/Z80_CPC_Timings_cheat_sheet.20230709.pdf): This document is invaluable for understanding the real timing cost of all Z80 instructions. While many resources list instruction timing in cycles or T-states, the Amstrad CPC has its own timing due to the Gate Array pausing the Z80 to access video memory. Therefore, it's more accurate to measure timing on the Amstrad CPC based on the cost of the NOP instruction.


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

Macro code can contain *calls* to other macros but it's not possible to define a new macro o use the directive **read**. If a macro contains a regular label (global or local to the module) and it is used more than once, the assembler will detect a symbol redefinition, which will cause an error. If a macro needs to use labels, they must be preceded by the symbol '!' which singnales them as **macro local labels**.

```
macro decnz_a
  or a
  jr z,!leave
  dec a
  !leave
mend
```

WinApe uses the symbol '@' to mark **macro local labels** but that symbol is used by ABASM to represent the current instruction's memory address too. As a result, ABASM departs from WinApe in this point and uses the symbol '!' instead.

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

# Changelog

- Version 1.1 - ??/??/????
  * Support for directive LIMIT
  * Support for local labels in macro code
  * New assembler flag --verbose added as an option
  * Some minor fixes and improvements

- Version 1.0 - 03/10/2024
  * First released version



