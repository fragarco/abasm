@echo off

REM *
REM * This file is just an example of how BASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ASM=python3 ../../src/basm.py
set DSK=python3 ../../src/dsk.py
set CDT=python3 ../../src/cdt.py

set LOADADDR=0x1200
set SOURCE=main
set TARGET=include

set RUNASM=%ASM% --start=%LOADADDR% %SOURCE%.asm 
set RUNDSK=%DSK% --new --put-bin %SOURCE%.bin --load-addr %LOADADDR% --map-file %SOURCE%.map --start-addr MAIN %TARGET%.dsk
set RUNCDT=%CDT% --new --name %TARGET% --put-bin %SOURCE%.bin --load-addr %LOADADDR% --map-file %SOURCE%.map --start-addr MAIN %TARGET%.cdt

IF "%1"=="clear" (
    del %SOURCE%.bin
    del %SOURCE%.lst
    del %SOURCE%.map
    del %TARGET%.dsk
    del %TARGET%.cdt
) ELSE (
    call %RUNASM% && call %RUNDSK% && call %RUNCDT% 
)

@endlocal
@echo on