setlocal enabledelayedexpansion
set objs=
for %%f in (lab7) do (
	ml /c /coff %%f.asm
	if not exist "%%f.obj" goto :error

	set "objs=!objs!%%f.obj "
)

link /SUBSYSTEM:CONSOLE /NOLOGO %objs% /OUT:prog.exe
prog.exe
pause
	del *.obj 2>nul
goto :EOF

:error
	del *.obj 2>nul
	del prog.exe 2>nul
	del .\CodeView\%%f.exe 2>nul
	pause