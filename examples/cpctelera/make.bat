@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

SET ABASMHOME=%~dp0..\..\

IF EXIST "%ABASMHOME%\bin" goto :abasm_tools_bin
	SET ASM=python "%ABASMHOME%\src\abasm.py" %*
	SET DSK=python "%ABASMHOME%\src\dsk.py"
    SET CDT=python "%ABASMHOME%\src\cdt.py"
    SET IMG=python "%ABASMHOME%\src\img.py"
	GOTO :abasm_tools_end
:abasm_tools_bin
	SET ASM="%ABASMHOME%\bin\abasm.exe" %*
	SET DSK="%ABASMHOME%\bin\dsk.exe"
    SET CDT="%ABASMHOME%\bin\cdt.exe"
    SET IMG="%ABASMHOME%\bin\img.exe"
:abasm_tools_end

set TARGET=cpctelera

IF "%1"=="clear" (
    del *.bin
    del *.lst
    del *.map
    del *.dsk
    del *.cdt
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
