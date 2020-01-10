.486					
.model flat, stdcall	
option casemap: none	

include \masm32\include\windows.INC
include \masm32\include\kernel32.INC
include \masm32\include\user32.INC
include \masm32\include\masm32.INC

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

WinMain proto :dword

.data
	caption1 				DB 		'Array before', 0
	caption2 				DB 		'Array after', 0
	ClassName1 				DB 		'WindowClass1', 0
	ClassName2 				DB 		'WindowClass2', 0
	hInstance HINSTANCE 	? 	
	wc1 WNDCLASSEX 			<?>		
	wc2 WNDCLASSEX 			<?>		
	formsOpened				DD		2
	
	wordLen  				EQU 	19
	w_width  				EQU 	300
	w_height 				EQU 	380
	w_x 					EQU 	600
	w_y 					EQU 	300
	w_dx 					EQU 	50
	
	buffer1	 				DB 		1000 dup(0)	
	buffer2	 				DB		1000 dup(0)	
	bufIndex 				DD 		0
	bufFlag 				DB 		0
	
	arr 					DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
							DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
							DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
							DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
							DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
							DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
	arrSize					EQU		15
	msk 					EQU		7FFFFh 
	
; 					 |1*19              |2*19              |3*19              |4*19
; 10101011110011011110111100010010001101000101011001111000101111000100100011010000
;         |8      |16     |24     |32             |16+32
	
get MACRO n
	PUSH eAX
	PUSH CX
	PUSH DX
	PUSH SI
	
	MOV AX, n
	MOV BX, 19
	MUL BX
	MOV BL, 8
	DIV BL
	
	MOV eBX, 0
	MOV BL, AL
	MOV eSI, eBX ; arrIndex
	MOV BL, AH ; leftOffset
	
	MOV CL, 32 - 19
	SUB CL, BL ; rightOffset
	
	MOV EBX, DWORD PTR arr[SI]
	BSWAP EBX
	SHR EBX, CL
	AND EBX, msk
	
	POP SI
	POP DX
	POP CX
	POP eAX
ENDM

set MACRO n, val
	PUSHA
	MOV EBX, val
	PUSH EBX
	
	MOV AX, n
	MOV BX, 19
	MUL BX
	MOV BL, 8
	DIV BL
	
	MOV EBX, 0
	MOV BL, AL
	MOV ESI, EBX ; arrIndex
	MOV BL, AH ; leftOffset
	
	MOV CL, 32 - 19
	SUB CL, BL ; rightOffset
		
	MOV EDX, DWORD PTR [EBP+ESI]
	BSWAP EDX
	MOV EBX, msk
	SHL EBX, CL
	NOT EBX ; EBX=msk2
	AND EDX, EBX 
	
	POP EBX
	AND EBX, msk
	SHL EBX, CL ; EBX=val
	
	OR EBX, EDX; EBX=result
	
	BSWAP EBX
    MOV DWORD PTR [EBP+ESI], EBX
	POPA
ENDM

find MACRO arraySize, val
	PUSH EBX
	PUSH EDX
	PUSH CX
	MOV EDX, val
	MOV CX, arraySize
	
	LOOP1:
		MOV AX, CX	
		DEC AX
		get AX
		CMP EBX, EDX
		JE FOUND
	LOOP LOOP1
	
	MOV AX, -1
	
	FOUND:
	POP CX
	POP EDX
	POP EBX
ENDM

count MACRO arraySize, val
	PUSH EDX
	PUSH CX
	MOV EAX, 0
	MOV EDX, val
	MOV CX, arraySize
	
	LOOP1:
		DEC CX
		get CX
		CMP EBX, EDX
		JNE NOT_EQ
			INC EAX
		NOT_EQ:
		INC CX
	LOOP LOOP1
	
	POP CX
	POP EDX
ENDM
	
.code
main:	
    INVOKE GetModuleHandle, NULL 
    MOV hInstance, EAX 
    INVOKE WinMain, hInstance
    INVOKE ExitProcess, EAX

WinMain PROC hInst:HINSTANCE
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
	IRP num, <1,2>
		MOV wc&num.cbSize, SIZEOF WNDCLASSEX 
		MOV wc&num.style, CS_HREDRAW OR CS_VREDRAW 
		MOV wc&num.lpfnWndProc, OFFSET Window&num
		MOV wc&num.cbClsExtra, NULL 
		MOV wc&num.cbWndExtra, NULL 
		PUSH hInst 
		POP wc&num.hInstance 
		MOV wc&num.hbrBackground, COLOR_WINDOW+1 
		MOV wc&num.lpszMenuName, NULL 
		MOV wc&num.lpszClassName, OFFSET ClassName&num 
		INVOKE LoadIcon, NULL, IDI_APPLICATION 
		MOV wc&num.hIcon, EAX 
		MOV wc&num.hIconSm, EAX 
		INVOKE LoadCursor, NULL, IDC_ARROW 
		MOV wc&num.hCursor, EAX 
		INVOKE RegisterClassEx, addr wc&num 
	ENDM
		
	CALL bufFill
		
    INVOKE CreateWindowEx, NULL, ADDR ClassName1, ADDR caption1, WS_OVERLAPPEDWINDOW , \
		   w_x, w_y, w_width, w_height, \ 
		   NULL, NULL, hInst, NULL
    MOV hwnd,EAX 
    INVOKE ShowWindow, hwnd, SW_SHOWNORMAL 
    INVOKE UpdateWindow, hwnd 
	
	MOV bufFlag, 1
	CALL calcResult
	CALL bufFill
	
	INVOKE CreateWindowEx, NULL, ADDR ClassName2, ADDR caption2, WS_OVERLAPPEDWINDOW , \
		   w_x + w_width + w_dx, w_y, w_width, w_height, \ 
		   NULL, NULL, hInst, NULL
    MOV hwnd, EAX 
    INVOKE ShowWindow, hwnd, SW_SHOWNORMAL 
    INVOKE UpdateWindow, hwnd
	
    .WHILE TRUE 
       INVOKE GetMessage, ADDR msg, NULL, 0, 0 
       .BREAK .IF (!EAX) 
	   INVOKE TranslateMessage, ADDR msg 
	   INVOKE DispatchMessage, ADDR msg 
    .ENDW 
    MOV EAX, msg.wParam 
    RET 
WinMain ENDP

IRP num, <1,2>
Window&num PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT 
    .IF uMsg==WM_DESTROY 
		MOV EBX, formsOpened
		CMP EBX, 1
		JNE continue
			invoke PostQuitMessage, NULL
		continue:
		DEC EBX
		MOV formsOpened, EBX
    .ELSEIF uMsg==WM_PAINT 
        INVOKE BeginPaint, hWnd, ADDR ps 
        MOV hdc, EAX 
        INVOKE GetClientRect, hWnd, ADDR rect 
		INVOKE DrawText, hdc, ADDR buffer&num, -1, ADDR rect, DT_CENTER 
        INVOKE EndPaint, hWnd, ADDR ps 
    .ELSE 
        INVOKE DefWindowProc, hWnd, uMsg, wParam, lParam 
        RET 
    .ENDIF 
    MOV EAX, 0
    RET 
Window&num ENDP 
ENDM

calcResult PROC uses EAX EBP
	LEA EBP, arr
	count arrSize, 0111100010010001101b
	; count arrSize, 0001010110011110001b
	set 0, eax
	RET
calcResult ENDP

toString PROC USES EAX EBX ECX
	MOV EAX, EBX
	MOV EBX, bufIndex
	MOV ECX, wordLen
	SHL eax, 32 - wordLen
	@print:
		MOV BYTE PTR [EBP+EBX], '1'
		SHL EAX, 1
		JC @one
			MOV BYTE PTR [EBP+EBX], '0'
		@one:
		INC EBX
	LOOP @print
	MOV bufIndex, EBX
	RET
toString ENDP

bufFill PROC USES EBX ECX ESI EBP edx
	XOR EBX, EBX
	MOV bufIndex, 0
	
	XOR ESI, ESI
	@LOOP:		
		LEA EBP, arr
		get SI
		CMP bufFlag, 1
		JE @buf2
		LEA EBP, buffer1
		JMP @write
@buf2:	LEA EBP, buffer2
@write:	CALL toString	
		MOV EBX, bufIndex
		MOV BYTE PTR [EBP+EBX], 13
		MOV BYTE PTR [EBP+EBX + 1], 10
		ADD bufIndex, 2			
	INC ESI
	CMP ESI, arrSize
	JNE @LOOP
	
	RET
bufFill ENDP

END main