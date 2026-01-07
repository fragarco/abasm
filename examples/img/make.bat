@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or real hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ASM=python3 "..\..\src\abasm.py"
set IMG=python3 "..\..\src\img.py"
set DSK=python3 "..\..\src\dsk.py"

set LOADADDR=0x1200
set SOURCE=image
set TARGET=img

IF "%1"=="clear" (
    del %SOURCE%.scn
    del %SOURCE%.scn.info
    del %TARGET%.dsk
) ELSE (
    call %IMG% assets/logo_aua.jpg --format scn --mode 0 --name %SOURCE%
    call %DSK% -n %TARGET%.dsk --put-ascii loadimg.bas
    call %DSK% %TARGET%.dsk --put-bin %SOURCE%.scn
)

@endlocal
@echo on
