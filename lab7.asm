.386
.model flat, stdcall
	EXTERN log:PROC

option casemap: none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
include \masm32\macros\macros.asm
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

.data					
	x  	 	    	DQ 		?
	xEnd	 	    DQ 		?
	xD		 	    DQ 		?
	e  	 	    	DQ 		?
	stdlog 	    	DQ 		?
	sum			    DQ 		?
	sum2		    DQ 		?  ; 2*sum
	xkn				DQ 		?  ; (x-1)/(x+1)^n
	xk2				DQ 		?  ; (x-1)/(x+1)^2
	n				DD 		?  
	nk				DD 		?  ; 2n+1
	t				DD		?
	
	tLeft 			EQU		0201
	tRight			EQU		0187
	tDown			EQU 	0203			
	bLeft 			EQU		0200
	bRight 			EQU		0188
	bUp				EQU		0202
	hLine			EQU		0205
	vLine			EQU		0186
	vRight			EQU		0204
	vLeft			EQU		0185
	hv				EQU		0206 
	endl			EQU 	10, 13, 0
	clwidth			EQU 	15
	clcount			EQU 	3
	
	top				DB		tLeft
					REPT 	clcount
						DB  clwidth DUP(hLine)
						DB 	tDown
					ENDM
					DB  	clwidth DUP(hLine)
					DB 		tRight
					DB 		endl
	left 			DB 		vLine, ' ', 0
	middle			DB 		' ', vLine, ' ', 0
	right			DB 		' ', vLine, endl
	header			DB 		vLine, '       x       '
					DB 		vLine, '      sum      '
					DB 		vLine, '      std      '
					DB 		vLine, '       n       '
					DB 		vLine
					DB 		endl
	hBottom			DB 		vRight
					REPT 	clcount
						DB  clwidth DUP(hLine)
						DB 	hv
					ENDM
					DB  	clwidth DUP(hLine)
					DB 		vLeft
					DB 		endl
	bottom			DB		bLeft
					REPT 	clcount
						DB  clwidth DUP(hLine)
						DB 	bUp
					ENDM
					DB  	clwidth DUP(hLine)
					DB 		bRight
					DB		endl
					
	inputmsg		DB		"Enter x1, x2, dx, e", endl
	inputerr		DB		"Input error", endl
	scanfmt 		DB 		"%lf %lf %lf %lf", 0
	strfmt			DB		'%s', 0
	doublefmt		DB		'  %5d      ', 0
	longfmt			DB		'  %9lf  ', 0
	strbuff			DB		30 dup(?)

.code
	
START:
	FINIT
	
	INVOKE crt_printf, OFFSET inputmsg
	INVOKE crt_scanf, OFFSET scanfmt, OFFSET x, OFFSET xEnd, OFFSET xD, OFFSET e 
	.IF EAX != 4
		INVOKE crt_printf, OFFSET inputerr
		INVOKE ExitProcess, 1
	.ENDIF
	
	print OFFSET top
	print OFFSET header
	print OFFSET hBottom
	
LOOP_DX:
    FLD x
	FLD1 
	FSUB 						; x-1
    FLD x 
	FLD1 	
    FADD 						; x+1
	FDIV
    FST sum 					; sum=(x-1)/(x+1)
    FST xkn 					; xkn=(x-1)/(x+1)
	FMUL ST, ST
    FSTP xk2	 				; xk2=(x-1)/(x+1)^2
	MOV n, 0
	MOV nk, 1
	
LOOP_ACC:
	MOV EBX, n
	INC EBX
	MOV n, EBX 					; n=n+1
	FLD xkn
	FMUL xk2
	FST xkn 					; xkn=(x-1)/(x+1)^2n+1
	MOV EBX, nk
	ADD EBX, 2
	MOV nk, EBX					; nk=2n+1
	FIDIV nk 					; (x-1)/(x+1)^2n+1 / 2n+1
	FLD ST						; dup
	FADD sum 		
	FSTP sum					; sum=sum+(x-1)/(x+1)^2n+1 / 2n+1
	FABS						; |(x-1)/(x+1)^2n+1 / 2n+1|
	FLD e						
	FCOMPP 		 				; e v |(x-1)/(x+1)^2n+1 / 2n+1|
	FSTSW AX
	SAHF
JB LOOP_ACC 
	
	print OFFSET left
	INVOKE crt_sprintf, OFFSET strbuff, OFFSET longfmt, x
	INVOKE crt_printf, OFFSET strfmt, OFFSET strbuff
	
	print OFFSET middle
	FLD sum
	MOV t, 2
	FILD t
	FMUL
	FSTP sum2	; sum2=sum*2
	INVOKE crt_sprintf, OFFSET strbuff, OFFSET longfmt, sum2
	INVOKE crt_printf, OFFSET strfmt, OFFSET strbuff
	
	print OFFSET middle
	FLDLN2
	FLD x
	FYL2X
	FSTP stdlog
	INVOKE crt_sprintf, OFFSET strbuff, OFFSET longfmt, stdlog
	INVOKE crt_printf, OFFSET strfmt, OFFSET strbuff
	
	print OFFSET middle
	INVOKE crt_printf, OFFSET doublefmt, n
	print OFFSET right
	
	FLD x
	FLD xD
	FADD
	FST x
	FLD xEnd
	FCOMPP 				
	FSTSW AX
	SAHF
JAE LOOP_DX
	print OFFSET bottom
	
EXIT:
	INVOKE ExitProcess, 0	
END START