.386					; Enable 80386+ instruction set
.model flat, stdcall	; Flat, 32-bit memory model (not used in 64-bit)
option casemap: none	; Case sensitive syntax

; MASM32 proto types for Win32 functions and structures
include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\masm32.inc
include c:\masm32\macros\macros.asm
; MASM32 object libraries
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\masm32.lib
; C function
include c:\masm32\include\msvcrt.inc
includelib c:\masm32\lib\msvcrt.lib

.data
	scanfFormat db "%lf %lf %lf %lf", 0
    formatInt db "% d", 0
    format   db   "% .10f", 0
	startMessage db 'Vavulin Nikita, group P3219', 13, 10, 0
	funcMessage db 'Function:  arcth(x)', 13, 10, 0
	welcome db 'Input left right dX E: ', 0
	inputError db 'Wrong input params.....', 0
	
	top db 218, 20 dup (196), 194, 20 dup(196), 194, 20 dup(196), 194, 20 dup(196), 191, 10, 0
	head db 179, 10 dup(' '), 'X', 9 dup(' '), 179, 9 dup(' '), 'Sum', 8 dup(' '), 179, 3 dup(' '), 'Standard value', 3 dup(' '), 179, 8 dup(' '), 'Count', 7 dup(' '), 179,10,  0
	under_head db 195, 20 dup (196), 197, 20 dup(196), 197, 20 dup(196), 197, 20 dup(196), 180, 10, 0
	bottom db 192, 20 dup (196), 193, 20 dup(196), 193, 20 dup(196), 193, 20 dup(196), 217, 10, 0
	space db ' ', 0
	vert db 179, 0
	newLine db 10, 0
	
	buffer db 20 dup(0)
	result dq 0
	xl dq ?
	xr dq ?
	delta dq ?
	eps dq 0.0001
	an dq ?
	sum dq 0
	two dq 2.0
	one dq 1.0
	onee dq 1.0000000000001
	yui dq 100.0
	x dq 0
	counter dw 0
.code
print_space macro
local forM
forM:
	pushad
		invoke crt_printf, offset space
	popad
loop forM
endm
start:
	
	invoke crt_printf, offset startMessage 
	invoke crt_printf, offset funcMessage
	invoke crt_printf, offset welcome
	invoke crt_scanf, offset scanfFormat, offset xl, offset xr, offset delta, offset eps 
	.IF eax != 4
		invoke crt_printf, offset inputError
		invoke ExitProcess, 1
	.ENDIF
	
	fld xl
	fcomp xr ;if xr > xl => поменять(xl, xr)
	fstsw ax
	sahf
	
	jbe skip
	fld xl
	fld xr
	fstp xl
	fstp xr
skip:
	
	fld delta
	fabs
	fstp delta
	
	fldz
	fcom delta ; check delta <= 0
	fstsw ax
	sahf
	
	jb skip2
		invoke crt_printf, offset inputError
		invoke ExitProcess, 1
skip2:

	fld eps
	fabs
	fstp eps
	
	fldz
	fcom eps ; check eps <= 0
	fstsw ax
	sahf ;ah в регистр флагов
	
	jb skip3
		invoke crt_printf, offset inputError
		invoke ExitProcess, 1
skip3:
	
	invoke crt_printf, offset top
	invoke crt_printf, offset head
	invoke crt_printf, offset under_head
	
	
	finit
	
	fld xr
	fadd eps 
	fstp xr
	
	fldz 
	fldz ;st(5,6) = x^2
	fld xl ;st(3,4) = x
	fldz   ;st(2,3) = sum
	fld eps ;st(1, 2) = eps
	fldz
	
forX:
	mov counter, 0
	fld st(3)

	fld one
	fdiv st, st(1)
	;fstp st(1)

	fst st(7) 
	fstp st(4)
	
	
	fmul st, st(4)
	
	fst st(5) ;save x^2
	
	fcomp onee ;skip Xi if |Xi| <= 1
	fstsw ax
	sahf
	jnae skipX
	
forSum:
	
	fld st(5) ;load an to st(0)
	fabs
	fcomp st(2)
	fstsw ax
	sahf
	jb next ;compare an with eps

	fild counter ;calculate a(n + 1) = a(n) * k
	fmul two
	fadd one
	fst st(1)
	fadd two
	fxch st(1)
	fdiv st, st(1)
	fdiv st, st(5) ;get a(n+1)
	fmul st, st(6)

	fst st(6) ; save new an
	faddp st(3), st ;sum += an
	mov dx, counter ;counter++
	inc dx
	mov counter, dx
	jmp forSum
endSum:
next:
	fld st(2) ;get sum from st(2)
	fstp sum
	fld st(3) ;get x from st(3)
	fstp x
	
	invoke crt_sprintf, offset buffer, offset format, x ;double to string
	invoke crt_strlen, offset buffer 
	invoke crt_printf, offset vert
	invoke crt_printf, offset space
	invoke crt_printf, offset buffer
	mov ecx, 19
	sub ecx, eax
	print_space
	
	xor eax, eax
	invoke crt_sprintf, offset buffer, offset format, sum 
	invoke crt_strlen, offset buffer 
	invoke crt_printf, offset vert
	invoke crt_printf, offset space
	invoke crt_printf, offset buffer
	mov ecx, 19
	sub ecx, eax
	print_space
	

	fld st(3)
	fstp st(1)
	fld1
	fsub st(1), st
	;fxch st(1)
	fld st(4)
	fstp st(1)
	fadd one
	fdiv st, st(1) 
	fstp x

	fstp st
	fldln2
	fld x
	fyl2x
	fdiv two 
	
	fst result
	
	xor eax, eax
	invoke crt_sprintf, offset buffer, offset format, result
	invoke crt_strlen, offset buffer
	
	invoke crt_printf, offset vert
	invoke crt_printf, offset space
	invoke crt_printf, offset buffer
	
	mov ecx, 19
	sub ecx, eax
	
	print_space
	
	xor eax, eax

	invoke crt_sprintf, offset buffer, offset formatInt, counter 
	invoke crt_strlen, offset buffer
	invoke crt_printf, offset vert
	invoke crt_printf, offset space
	invoke crt_printf, offset buffer
	mov ecx, 19
	sub ecx, eax
	print_space
	
	
	invoke crt_printf, offset vert
	invoke crt_printf, offset newLine
	
skipX:
	
	xor eax, eax
	fld delta
	faddp st(4), st(0)
	fld st(3)
	fcomp xr
	fstsw ax
	sahf
	
	jbe forX
endForX:

	invoke crt_printf, offset bottom
	invoke ExitProcess, 0
end start
