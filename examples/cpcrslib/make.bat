@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ASM=python3 ../../src/abasm.py %*
set DSK=python3 ../../src/dsk.py

set LOADADDR=0x4000
set TARGET=cpcrslib

IF "%1"=="clear" (
    del *.bin
    del *.lst
    del *.map
    del *.dsk
) ELSE (
    call %DSK% %TARGET%.dsk --new
    for %%x in (example1, example2, example3, example4, example5) do (
        call %ASM% --start %LOADADDR% %%x.asm && call %DSK% %TARGET%.dsk --put-bin %%x.bin
    )
)

@endlocal
@echo on