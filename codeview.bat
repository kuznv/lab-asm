e:
cd "E:\asm"
setlocal enabledelayedexpansion
set objs=
for %%f in (lab4) do (
	ml /c %%f.asm
	if not exist "%%f.obj" goto :error

	set "objs=!objs!%%f.obj "
)

link16 %objs%, prog.exe;

copy prog.exe .\CodeView || goto :error
"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" -noconsole -c "prog.exe" /f
	del *.obj 2>nul
	del prog.exe 2>nul
	del .\CodeView\%%f.exe 2>nul
goto :EOF

:error
	del *.obj 2>nul
	del prog.exe 2>nul
	del .\CodeView\%%f.exe 2>nul
	pause