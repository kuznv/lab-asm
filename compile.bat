@echo off

if exist lab6.obj del lab6.obj
if exist lab6.exe del lab6.exe

\masm32\bin\ml /c lab6.asm
if errorlevel 1 goto errasm

\masm32\bin\Link16 /TINY "lab6.obj","lab6.com";
if errorlevel 1 goto errlink

del lab6.obj

goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd
pause