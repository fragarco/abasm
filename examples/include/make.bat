@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

SET ABASMHOME=%~dp0..\..\

IF EXIST "%ABASMHOME%\bin" goto :abasm_tools_bin
	SET ASM=python "%ABASMHOME%\src\abasm.py"
	SET DSK=python "%ABASMHOME%\src\dsk.py"
    SET CDT=python "%ABASMHOME%\src\cdt.py"
    SET IMG=python "%ABASMHOME%\src\img.py"
	GOTO :abasm_tools_end
:abasm_tools_bin
	SET ASM="%ABASMHOME%\bin\abasm.exe"
	SET DSK="%ABASMHOME%\bin\dsk.exe"
    SET CDT="%ABASMHOME%\bin\cdt.exe"
    SET IMG="%ABASMHOME%\bin\img.exe"
:abasm_tools_end

set LOADADDR=0x1200
set SOURCE=main
set TARGET=include

set RUNASM=%ASM% --start=%LOADADDR% %SOURCE%.asm 
set RUNDSK=%DSK% %TARGET%.dsk --new --put-bin %SOURCE%.bin --load-addr %LOADADDR% --map-file %SOURCE%.map --start-addr MAIN

IF "%1"=="clear" (
    del *.bin
    del *.lst
    del *.map
    del *.dsk
    del *.cdt
) ELSE (
    call %RUNASM% && call %RUNDSK%
)

@endlocal
@echo on