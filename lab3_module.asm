; ��������  ��� �������� ������ �� ����� ��������� ������
; �� ������� �������� ������� ���������, � ������ - ���������������.
     ; ������� ���������  ��������������  �������� ������ ��� ��������-
; ������� ��������� � �������� ��.  ��� ����������� ��� ������ �������-
; ��� �����������   �  ������ ������� ��������� � �������� �������� ���
; ��������������� ���������.   ���������������  ���������  ������������
; �������������� ������,   ���������� �� ������� ���������� � ��������-
; ���� � ��������� �������. �������� ���������� �� ��������������� ���-
; ������ ������������ ����� ����.  ��� ����������� ��������������� ���-
; ������ ���������� ������ ���� ������������ ��� ��������� �  ���������
; � �����.  ��������������� ��������� ���������� ���� ������� ���������
; � �� ����� ������������ �������� ������.

     ; �������� ��������������� ���������, ���������� � ��� ������������
; �� ���������� ���������� �� � ������� 1 � ������������ � ��������� ��-
; �����.

     ; ������������ ������ ����������� � ��� �����: ������� ����������-
; ������ ��������������� ��������� � �������������� �� �������.   �����
; ����� ���������������  ��������� � ������������ � �������� ����������
; � ��������� ������, ���������������� ������� ���������, ������������-
; �� �� ���������� ���������� � �������������� ������ ���������� �����-
; ���� �������.  ��������� � ������ ������ ������������������  ��������
; �� ������������, � �������������.

     ; ��������������� ��������� ������ ��������� ���  ������������
; ��������, � ���������� � �������� AX ������� �������� ���� ���������-
; ����� ������ ������� � ��������� ���� ��� �������������� ���� ������-
; ���� ������ (��������, �������� ��������� � ������������� ����� �����
; �� ����� ���� ��������� � ��������� ���������� �������� � �.�.).

; ��� �������� ������:
    ; 1.3. ���������� ���������� �������� � ������� �����.
	
; �������� ������ ���������� ������������� �
   ; 2.8. ����������� ������������� � ������������ ������� �� ������.
 
 
CODE SEGMENT PARA PUBLIC 'code'
	.486
	ASSUME CS: code
	
newLine PROC
	PUSHA
	MOV AH, 2
	MOV DL, 10	
	INT 21h
	MOV DL, 13
	INT 21h
	POPA
	MOV AX, 0
	RET 0
newLine ENDP

readInput PROC
	PUSHA
	MOV BP, SP
	
	showMenu:
	MOV AH, 09h ; write string
	MOV DX, [BP+16+4] ; OFFSET menuCaption
	INT 21h
	MOV DX, [BP+16+6] ; OFFSET menu1
	INT 21h
	MOV DX, [BP+16+8] ; OFFSET menu2
	INT 21h
	MOV DX, [BP+16+10] ; OFFSET menu3
	INT 21h
	
	MOV AH, 01h ; read char
	INT 21h
	
	m1: 
	CMP AL, '1'
	JNE m2
		MOV BL, 0Fh
		JMP menuExit
	
	m2: 
	CMP AL, '2'
	JNE m3
		MOV BL, 02h
		JMP menuExit
	
	m3: 
	CMP AL, '3'
	JNE showMenu
		MOV BL, 04h
	menuExit:
	
	CALL newLine
	
	MOV AH, 09h ; set color
	MOV AL, " " 
	MOV CX, 8+1 
	INT 10h
	
	MOV AH, 0Ah ; read string
	MOV DX, [BP+16+2] ; chars
	INT 21h
	
	MOV SI, [BP+16+2] ; chars
	MOV ECX, 0
	ADD SI, 1 ; charsR
	MOV CL, [SI] ; charsR
	ADD SI, 1 ; first char
	
	MOV EDX, 0 ; input
	bytes:
		MOV EBX, 0
		MOV BL, [SI]
		CMP BL, '9'
		JG hex
			SUB BL, '0'
			JMP digit
		hex:
			SUB BL, 'A' - 10
		digit:
			SHL EDX, 4
			OR EDX, EBX
			INC SI ; next char
	LOOP bytes
		
	MOV BX, [BP+16+12] ; OFFSET input
	MOV [BX], EDX ; write input
	
	CALL newLine
	POPA
	MOV AX, 0
	RET 12
readInput ENDP

openFile PROC
	PUSHA
	MOV BP, SP
	
	MOV AH, 3dh ; �������� ����� �� ������
	MOV AL, 1
	MOV DX, [BP+16+2] ; offset fileName
	INT 21h
	
	JNC FILE_CREATED
		MOV AH, 3ch ; �������� ����� ��� ������
		MOV CX, 0
		INT 21h
		JC FILE_ERROR
			MOV AH, 3dh ; ��������� ��������
			MOV AL, 1
			MOV DX, [BP+16+2]
			INT 21h
			JC FILE_ERROR
	
	FILE_CREATED:
	
	MOV BX, AX ; ����������� ��������� � ����� �����
	MOV AH, 42h
	MOV DX, 0
	MOV AL, 2
	INT 21h
	JC FILE_ERROR
	
	MOV AX, BX
	MOV BX, [BP+16+4] ; offset fileHandler
	MOV [BX], AX
	
	MOV AX, 0
	JMP DONE
	
	FILE_ERROR:
		MOV AH, 3eh ; �������� �����
		INT 21h
		MOV AX, 1
	
	DONE:
	POPA
	RET 4
openFile ENDP

printResult PROC
	PUSHAD
	MOV BP, SP
	
	MOV EDX, [BP+32+2] ; input
	; BSWAP EDX
	MOV [BP+32+2], EDX ; input
	
	MOV EBX, EDX
	SHR EBX, 31
	SHL EDX, 1
	MOV [BP+32+2], EDX ; input
	
	CMP EBX, 0
	JE POSITIVE
		MOV AH, 40h
		MOV BX, '-'
		
		MOV SI, [BP+32+6] ; OFFSET printBuffer
		MOV [SI], BX ; write to printBuffer
		MOV DX, SI
		MOV BX, [BP+32+8] ; fileHandler
		MOV AH, 40h
		MOV CX, 1
		INT 21h
	POSITIVE:
	
	MOV EDX, [BP+32+2] ; input
	MOV EBX, EDX
	SHR EBX, 31
	SHL EDX, 1
	MOV [BP+32+2], EDX ; input
	
	CMP EBX, 0
	JE FIRST_BIT_0
		MOV AH, 40h
		MOV BX, '1'
		
		MOV SI, [BP+32+6] ; OFFSET printBuffer
		MOV [SI], BX ; write to printBuffer
		MOV DX, SI
		MOV BX, [BP+32+8] ; fileHandler
		MOV AH, 40h
		MOV CX, 1
		INT 21h
	FIRST_BIT_0:
	
	; skip 0 
	MOV CX, 10
	MOV EDX, [BP+32+2] ; input
	SKIP_0:
		MOV EBX, EDX
		SHR EBX, 29
		CMP EBX, 0
		JNE SKIP_0_END
			SHL EDX, 3
	LOOP SKIP_0
		
	SKIP_0_END:
	MOV [BP+32+2], EDX ; input
	
	OCT_LOOP:
		PUSH CX
		MOV EDX, [BP+32+2] ; input
		MOV EBX, EDX
		SHR EBX, 29
		SHL EDX, 3
		MOV [BP+32+2], EDX
		
		ADD EBX, '0' ; char
		MOV SI, [BP+32+6] ; OFFSET printBuffer
		MOV [SI], BX ; write to printBuffer
		MOV DX, SI
		MOV BX, [BP+32+8] ; fileHandler
		
		MOV AH, 40h
		MOV CX, 1
		INT 21h
		POP CX
	LOOP OCT_LOOP
	
	POPAD
	MOV AH, 0
	RET 8
printResult ENDP

CODE ENDS

END