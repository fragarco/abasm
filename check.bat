@echo off

IF "%1"=="--notest" (
    call mypy . --explicit-package-bases
) ELSE (
    call mypy . --explicit-package-bases
    call python -m unittest -b
)

@echo on
