.386					
.model flat, stdcall	
option casemap: none	

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
include macro.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

WinMain proto :dword

.data
	ClassName1 db 'WindowClass1', 0
	ClassName2 db 'WindowClass2', 0
	title1 db 'Initial', 0
	title2 db 'Result', 0
	array dd 11100101001110001111111000110010b, 10101101010111001101000110110111b, 
			 00011101010000001001100111100011b, 01011000110101010001000101100101b, 
			 11000011011011011101110101010100b, 10101111101010110100111010110011b, 
			 01010011110100101110001110110000b, 11010010110101000011110100000100b, 
			 11011101101100001001100100001001b, 10011000101101011000011110101101b, 
			 10010101110110111011010010111010b
	buffer1	 db	1000 dup(0)	
	buffer2	 db	1000 dup(0)	
	currentBufferIndex dd 0
	bufferChangeFlag db 0
	
.data?
	hInstance HINSTANCE ? 	; Instance handle
	wc1 WNDCLASSEX <?>		; Window class
	wc2 WNDCLASSEX <?>		; Window class
	
.const
	WORD_SIZE  equ 22
	ITEM_COUNT equ 16
	WORD_MASK  equ 11111111111111111111110000000000b
	
	WINDOW_WIDTH  equ 300
	WINDOW_HEIGHT equ 380
	WINDOW_X equ 600
	WINDOW_Y equ 300
	WINDOW_SPACE equ 50
	
.code
main:	
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
	irp num, <1,2>
    mov   wc&num.cbSize,SIZEOF WNDCLASSEX 
    mov   wc&num.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc&num.lpfnWndProc, OFFSET Window&num
    mov   wc&num.cbClsExtra,NULL 
    mov   wc&num.cbWndExtra,NULL 
    push  hInst 
    pop   wc&num.hInstance 
    mov   wc&num.hbrBackground,COLOR_WINDOW+1 
    mov   wc&num.lpszMenuName,NULL 
    mov   wc&num.lpszClassName,OFFSET ClassName&num 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc&num.hIcon,eax 
    mov   wc&num.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc&num.hCursor,eax 
    invoke RegisterClassEx, addr wc&num 
	endm
		
	;==============================================================================
	call arrayToBuffer
		
    invoke CreateWindowEx,NULL,ADDR ClassName1,ADDR title1, WS_OVERLAPPEDWINDOW , \
		   WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, \ 
		   NULL,NULL, hInst,NULL
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
	
	mov bufferChangeFlag, 1
	call makeResultArray
	call arrayToBuffer
	
	invoke CreateWindowEx,NULL,ADDR ClassName2,ADDR title2, WS_OVERLAPPEDWINDOW , \
		   WINDOW_X + WINDOW_WIDTH + WINDOW_SPACE, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, \ 
		   NULL,NULL, hInst,NULL
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd
	
    .WHILE TRUE 
       invoke GetMessage, ADDR msg,NULL,0,0 
       .BREAK .IF (!eax) 
	   invoke TranslateMessage, ADDR msg 
	   invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov eax, msg.wParam 
    ret 
WinMain endp

irp num, <1,2>
Window&num proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_PAINT 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        invoke GetClientRect,hWnd, ADDR rect 
		invoke DrawText, hdc,ADDR buffer&num,-1, ADDR rect, DT_CENTER 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor   eax, eax 
    ret 
Window&num endp 
endm
makeResultElement proc uses cx dx
	countSetBits
	mov cx, WORD_SIZE
	sub cx, dx
	
	mov ebx, WORD_MASK
	shl ebx, cl

	ret
makeResultElement endp

makeResultArray proc uses esi edi ebp cx ebx
	mov cx, ITEM_COUNT
	xor esi, esi
	xor edi, edi
	lea ebp, array
	RESULT_ARRAY_LOOP:
		call makeResultElement
		setElement
		inc si
		inc di
	loop RESULT_ARRAY_LOOP
	
	ret
makeResultArray endp

; ??? = ?????
; EBP = ????? ??????
wordToBuffer proc uses eax ebx ecx
	mov eax, ebx
	mov ebx, currentBufferIndex
	mov ecx, WORD_SIZE
	@print:
		mov byte ptr [ebp+ebx], '1'
		shl eax, 1
		jc @not_zero
			mov byte ptr [ebp+ebx], '0'
		@not_zero:
		inc ebx
	loop @print
	mov currentBufferIndex, ebx
	
	ret
wordToBuffer endp

; EDX = àäðåñ áóôåðà
arrayToBuffer proc uses ebx ecx esi ebp edx
	xor ebx, ebx
	mov currentBufferIndex, 0
	
	xor esi, esi
	@loop:		
		lea ebp, array
		getElement
		cmp bufferChangeFlag, 1
		je @buf2
		lea ebp, buffer1
		jmp @write
@buf2:	lea ebp, buffer2
@write:	call wordToBuffer	
		mov ebx, currentBufferIndex
		mov byte ptr [ebp+ebx], 13
		mov byte ptr [ebp+ebx + 1], 10
		add currentBufferIndex, 2			
	inc esi
	cmp esi, ITEM_COUNT
	jne @loop
	
	ret
arrayToBuffer endp

end main