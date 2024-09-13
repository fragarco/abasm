@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ASM=python3 ../../src/abasm.py
set DSK=python3 ../../src/dsk.py
set CDT=python3 ../../src/cdt.py

set LOADADDR=0x8000
set SOURCE=main
set TARGET=game

set RUNASM=%ASM% --start=%LOADADDR% %SOURCE%.asm 
set RUNDSK=%DSK% %TARGET%.dsk --new --put-bin %SOURCE%.bin --load-addr %LOADADDR% --start-addr %LOADADDR%
set RUNCDT=%CDT% %TARGET%.cdt --new --name %TARGET% --put-bin %SOURCE%.bin --load-addr %LOADADDR% --start-addr %LOADADDR% 

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