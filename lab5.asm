; Разрядность слова некоторого гипотетического процессора - N бит
; (число бит  для каждого варианта  различно  и  определено в таблице 1). Слова
; могут  принимать  положительные  или  отрицательные  значения.  Отрицательные
; значения хранятся в дополнительном коде.
     ; Моделирование работы с данными такого вида осуществляется средствами IBM
; PC (семейство процессоров  80х86).  Объект моделирования:  массив N-разрядных
; слов из 15-20 элементов.  Элементы располагаются в памяти реальной машины без
; промежутков (т.е. младшие разряды  одного слова и старшие разряды  следующего
; могут размещаться в одном байте).
     ; Для решения поставленной задачи написать следующие макроопределения:
 ; 1) Чтение элемента из моделируемого массива по его порядковому номеру;
 ; 2) Запись элемента в массив на указанное место;
 ; 3) Задано в таблице 1 (отдельно для каждого варианта). В некоторых вариантах
 ; это макроопределение должно возвращать результат работы в регистре AX.
     ; Написать программу на языке ассемблера,  в которой задаётся моделируемый
; массив.  Дальнейшие действия  с этим массивом описаны для каждого  варианта в
; таблице 1 (номер варианта указан в столбце "В").  Необходимо использовать все
; разработанные  макроопределения.   Для  всех  вычислений  нужно  использовать
; исходные, а не результирующие значения элементов.
     ; Вывод на экран  исходного и результирующего массивов  осуществить в виде
; двух панелей (как в Norton Commander'е). Исходный массив размещается на левой
; панели, результирующий - на правой.

; Вариант: 8
; Количество бит: 19 
; Поиск заданного значения в массиве: AX={номер элемента} (если не найдено, -1).                        
; В массиве подсчитываются все вхождения некоторого наперёд заданного значения. Результат записывается на место первого элемента в массиве.

 
.MODEL	small

DATA SEGMENT PARA PUBLIC 'data'
	arr 			DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
	res 			DB 		0ABh, 0CDh, 0EFh, 012h, 034h, 056h, 078h, 0BCh, 048h, 0D0h
	arrSize			EQU		4
	msk 			EQU 	7FFFFh 
	
	tLeft 			EQU		0201
	tRight			EQU		0187
	tDown			EQU 	0203			
	bLeft 			EQU		0200
	bRight 			EQU		0188
	bUp				EQU		0202
	hLine			EQU		0205
	vLine			EQU		0186
	hv				EQU		0206 
	
	top				DB		tLeft
					DB  	21 DUP(hLine)
					DB 		tDown
					DB  	21 DUP(hLine)
					DB 		tRight
					DB 		10, 13, '$'
	bottom			DB 		bLeft
					DB  	21 DUP(hLine)
					DB 		bUp
					DB  	21 DUP(hLine)
					DB 		bRight
					DB 		10, 13, '$'
	left 			DB 		vLine, ' ', '$'
	middle			DB 		' ', vLine, ' ', '$'
	right			DB 		' ', vLine, 10, 13, '$'
										
						
DATA ENDS

STACK SEGMENT PARA STACK 'stack'
	DB 100h DUP(0)
STACK ENDS

CODE SEGMENT PARA PUBLIC 'code'
	.486
	ASSUME CS: CODE, DS: DATA, SS: STACK
	
get MACRO array, n
	PUSH AX
	PUSH CX
	PUSH DX
	PUSH SI
	
	MOV AX, n
	MOV BX, 19
	MUL BX
	MOV BL, 8
	DIV BL
	
	MOV BX, 0
	MOV BL, AL
	MOV SI, BX ; arrIndex
	MOV BL, AH ; leftOffset
	
	MOV CL, 32 - 19
	SUB CL, BL ; rightOffset
	
	MOV EBX, DWORD PTR array[SI]
	BSWAP EBX
	SHR EBX, CL
	AND EBX, msk
	
	POP SI
	POP DX
	POP CX
	POP AX
ENDM

set MACRO array, n, val
	PUSHA
	MOV EBX, val
	PUSH EBX
	
	MOV AX, n
	MOV BX, 19
	MUL BX
	MOV BL, 8
	DIV BL
	
	MOV BX, 0
	MOV BL, AL
	MOV SI, BX ; arrIndex
	MOV BL, AH ; leftOffset
	
	MOV CL, 32 - 19
	SUB CL, BL ; rightOffset
		
	MOV EDX, DWORD PTR array[SI]
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
    MOV DWORD PTR array[SI], EBX
	POPA
ENDM

find MACRO array, arraySize, val
	PUSH EBX
	PUSH EDX
	PUSH CX
	MOV EDX, val
	MOV CX, arraySize
	
	LOOP1:
		MOV AX, CX	
		DEC AX
		get array, AX
		CMP EBX, EDX
		JE FOUND
	LOOP LOOP1
	
	MOV AX, -1
	
	FOUND:
	POP CX
	POP EDX
	POP EBX
ENDM

count MACRO array, arraySize, val
	PUSH EDX
	PUSH CX
	MOV EAX, 0
	MOV EDX, val
	MOV CX, arraySize
	
	LOOP1:
		DEC CX
		get array, CX
		CMP EBX, EDX
		JNE NOT_EQ
			INC EAX
		NOT_EQ:
		INC CX
	LOOP LOOP1
	
	POP CX
	POP EDX
ENDM

printBits PROC
	PUSHAD
	MOV BP, SP
	MOV EBX, [BP+32+4]
	MOV CX, [BP+32+2]
	MOV AX, 32
	SUB AX, CX
	MOV CX, AX
	SHL EBX, CL 
	MOV CX, [BP+32+2]
	MOV AH, 02h
	BIT_LOOP:
		MOV EDX, EBX
		SHR EDX, 31
		SHL EBX, 1
		ADD DL, '0'
		INT 21h
	LOOP BIT_LOOP
	POPAD
	RET 6
printBits ENDP

; 					 |1*19              |2*19              |3*19              |4*19
; 10101011110011011110111100010010001101000101011001111000101111000100100011010000
;         |8      |16     |24     |32             |16+32
			   
	
START:
	MOV AX, DATA				
	MOV DS, AX
	
PART1:
	count arr, arrSize, 0111100010010001101b
	; count arr, arrSize, 0001010110011110001b
	set res, 0, EAX

	MOV AH, 09h
	MOV DX, OFFSET top
	INT 21h

	MOV CX, 0
	ARR_LOOP:
		MOV DX, OFFSET left
		INT 21h
	
		get arr, CX
		PUSH EBX
		PUSH 19
		CALL printBits
	
		MOV DX, OFFSET middle
		INT 21h
	
		get res, CX
		PUSH EBX
		PUSH 19
		CALL printBits

		MOV DX, OFFSET right
		INT 21h
	
		INC CX
		CMP CX, arrSize
	JL ARR_LOOP
	
	MOV DX, OFFSET bottom
	INT 21h
EXIT:
	MOV EAX, 4C00h				
	INT 21h					
CODE ENDS
	
END START