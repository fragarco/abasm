@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or real hardware for the Amstrad CPC
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
set SOURCE=image
set TARGET=img

IF "%1"=="clear" (
    del %SOURCE%.scn
    del %SOURCE%.scn.info
    del %TARGET%.dsk
    del %TARGET%.cdt
) ELSE (
    call %IMG% assets/logo_aua.jpg --format scn --mode 0 --name %SOURCE%
    call %DSK% -n %TARGET%.dsk --put-ascii loadimg.bas
    call %DSK% %TARGET%.dsk --put-bin %SOURCE%.scn
)

@endlocal
@echo on
