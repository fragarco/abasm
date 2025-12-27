@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ASM=python3 ../../src/abasm.py %*
set DSK=python3 ../../src/dsk.py
set TARGET=cpctelera

IF "%1"=="clear" (
    del *.bin
    del *.lst
    del *.map
    del *.dsk
) ELSE (
    call %DSK% %TARGET%.dsk --new
    for %%x in (e01hello, e02box, e03struc, e04hflip) do (
        call %ASM% --start 0x4000 %%x.asm && call %DSK% %TARGET%.dsk --put-bin %%x.bin --load-addr=0x4000 --start-addr=0x4000
    )
    for %%x in (e05flipm, e06card) do (
        call %ASM% --start 0x2000 %%x.asm && call %DSK% %TARGET%.dsk --put-bin %%x.bin --load-addr=0x2000 --start-addr=0x2000
    )
)

@endlocal
@echo on
