# Introduction

BASM is a cross-assembler specifically designed for the Amstrad CPC platform and its Z80 CPU. Developed in Python 3, its main goal is to provide a lightweight and highly portable tool for programmers interested in writing assembly code for this classic 8-bit platform. With no external libraries or third-party tools required, BASM can run on any system with a Python 3 interpreter. Additionally, the project includes other tools, also written in Python and with no dependencies, to package the assembler’s output into DSK or CDT files.

BASM is based on the fantastic pyZ80 project, initially created by Andrew Collier and later modified by Simon Owen.

## Why Another Assembler for Amstrad?

BASM was conceived from the idea of having a portable tool that is easy to modify by anyone, without relying on specific operating systems or development environments. One of its goals is to provide a syntax compatible with the old MAXAM assembler, WinAPE syntax, and Virtual Machine Simulator. This gives developers several options to debug their code during development.

However, if you're looking for efficiency rather than portability and ease of modification, you may want to try the following assemblers:

* [Pasmo](https://pasmo.speccy.org/)
* [ASZ80](https://shop-pdp.net/ashtml/)
* [Rasm](https://github.com/EdouardBERGE/rasm)

# Basic Usage

To assemble a source file written in assembly language (e.g., `program.asm`), simply run the following command:

```
python3 basm.py <program.asm> [options]
```

This command will assemble the `program.asm` file and generate a binary file with the same name, `program.bin`.

## Available Options

- `-d` or `--define`: Allows defining `SYMBOL=VALUE` pairs. These symbols can be used in the code as constants or labels. This option can be used multiple times to define several symbols.
- `--start`: Defines the memory address that will be used as the starting point for loading the program. By default, this address is `0x4000`, but it can also be set directly in the code using the `ORG` directive.
- `-o` or `--output`: Specifies the name of the output binary file. If this option is not used, the name of the input file will be used, with its extension changed to `.bin`.

## **Usage Examples

Define a constant used in the code:

```
python3 basm.py program.asm -d MY_CONSTANT=100
```

Set the exact name of the assembled binary file:

```
python3 basm.py program.asm -o output.bin
```

Set the starting memory address for calculating jumps and other relative references in the source code, for example to `0x2000`:

```
python3 basm.py program.asm --start 0x2000
```
