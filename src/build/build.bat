@echo off

rmdir /Q /S %~dp0\..\..\bin\lib
xcopy /Q /S %~dp0\..\lib\  %~dp0\..\..\bin\lib\

SET COMMON_FLAGS=--onefile -p%~dp0\..\ --distpath %~dp0\..\..\bin

SET ABASM=pyinstaller %~dp0\..\abasm.py %COMMON_FLAGS%
SET DSK=pyinstaller %~dp0\..\dsk.py %COMMON_FLAGS%
SET CDT=pyinstaller %~dp0\..\cdt.py %COMMON_FLAGS%
SET IMG=pyinstaller %~dp0\..\img.py %COMMON_FLAGS%
SET ASMPRJ=pyinstaller %~dp0\..\asmprj.py %COMMON_FLAGS%

CALL %ABASM% && CALL %DSK% && CALL %CDT% && CALL %IMG% && CALL %ASMPRJ%
@echo on