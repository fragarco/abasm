@echo off
REM Example batch file that converts Markdown files to HTML
REM using PANDOC (must be present in the system) and its default HTML template.

SET PANDOC=pandoc --standalone --variable=maxwidth:50em

IF "%1"=="clear" (
    del .\html\en\*.html
    del .\html\es\*.html
    rmdir .\html\en
    rmdir .\html\es
    rmdir .\html
) ELSE (
    if not exist ".\html" mkdir .\html
    if not exist ".\html\en" mkdir .\html\en
    if not exist ".\html\es" mkdir .\html\es

    %PANDOC% .\en\abasm.md -o .\html\en\abasm.html
    %PANDOC% .\en\asmprj.md -o .\html\en\asmprj.html
    %PANDOC% .\en\cdt.md -o .\html\en\cdt.html
    %PANDOC% .\en\dsk.md -o .\html\en\dsk.html
    %PANDOC% .\en\bindiff.md -o .\html\en\bindiff.html
    %PANDOC% .\en\img.md -o .\html\en\img.html
    
    %PANDOC% .\es\abasm.md -o .\html\es\abasm.html
    %PANDOC% .\es\asmprj.md -o .\html\es\asmprj.html
    %PANDOC% .\es\cdt.md -o .\html\es\cdt.html
    %PANDOC% .\es\dsk.md -o .\html\es\dsk.html
    %PANDOC% .\es\bindiff.md -o .\html\es\bindiff.html
    %PANDOC% .\es\img.md -o .\html\es\img.html
)

@echo on
