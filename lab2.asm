; Ќаписать программу на €зыке јссемблер в которой осущест-
; вл€етс€ формирование двух строк из исходной строки в соответствии с
; вариантом задани€. »сходна€ строка длиной 64 байта содержит произволь-
; ный набор символов латинского алфавита, включа€ строчные и прописные
; буквы, цифры, знаки препинани€ и пробелы. Ѕитова€ строка длиной 64
; разр€да (может быть описана как четверное слово: QWORD) устанавливает
; необходимость обработки соответствующего номеру бита в битовой строке
; номера байта из исходной строки, причем если бит установлен в 1, то
; соответствующий ему байт должен быть обработан при формировании первой
; строки результата.
; ƒействи€ по формированию первой и второй строк результата, в со-
; ответствии с вариантом задани€, выбираютс€ из таблиц 1 и 2 соответс-
; твенно. ‘ормирование первой строки результата производитс€ в пр€мом
; направлении, второй строки результата в обратном.

; ‘ормирование первой строки результата
; 2:		все символы из исходной строки €вл€ющиес€ прописными буквами

; ‘ормирование второй строки результата
; 3:		до первого найденного в исходной строке символа '.' за которым следует прописна€ буква

; ѕримечание: если указанна€ комбинаци€ символов в исходной строке
; не обнаружена, то исходна€ строка копируетс€ целиком. ѕри формировании
; второй строки результата пробелы не учитываютс€.

.MODEL	small

DATA SEGMENT PARA PUBLIC 'data'
	maskBytes		DB			 01101011b, 11111111b, 11001010b, 11001010b, 11001010b, 11001010b, 11001010b, 11001010b
	s 						DB 			"aBcd fghij lm.nop RSTUVW 1234567890YZ1234 67890abcd.Efghijmn.PYU$"
	res1					DB			65 DUP(0)
	res2					DB			65 DUP(0)
	sOffset				DW			OFFSET s
	res1Offset		DW 			OFFSET res1
	res2Offset		DW 			OFFSET res2 + 63
	maskOffset		DW			OFFSET maskBytes
	bitMask				DB			0
	maskByte			DB			0
	bytesLeft			DW 			8
	dotOffset			DW 			0
	
DATA ENDS

CODE SEGMENT PARA PUBLIC 'code'
	.486
	ASSUME CS: CODE, DS: DATA
	
START:
	MOV EAX, DATA				
	MOV DS, EAX	
	
PART1:

	MOV DX, OFFSET s
	MOV AH, 9
	INT 21H
	
	MOV AH, 2
	MOV DL, 10
	INT 21H
	MOV DL, 13
	INT 21H

	MOV CX, bytesLeft
	BYTES_LOOP:
		MOV bytesLeft, CX
		 
		MOV BX, maskOffset
		MOV BX, [BX]
		MOV maskByte, BL
		MOV bitMask, 1 SHL 7
		
		MOV CX, 8
		BITS_LOOP:
			MOV BX, sOffset
			MOV DL, [BX]
			
			MOV BL, maskByte
			AND BL, bitMask
			
			MOV AH, 2
			
			CMP BL, 0
			JE MASK_0
			JMP MASK_1
			
			MASK_0:
				MOV DL, '0'
				INT 21H
				JMP SKIP
			
			MASK_1:
				MOV DL, '1'
				INT 21H
			
			MOV BX, sOffset
			MOV DL, [BX]
		
			CMP DL, 'A'
			JL SKIP
			
			CMP DL, 'Z'
			JG SKIP
		
			MOV BX, res1Offset
			MOV [BX], DL
			INC res1Offset
		
		SKIP:
			MOV AL, bitMask
			SHR AL, 1
			MOV bitMask, AL
			
			INC sOffset
		LOOP BITS_LOOP
	
		INC maskOffset
		MOV CX, bytesLeft
	LOOP BYTES_LOOP
	
;	/n	
	MOV AH, 2
	MOV DL, 10
	INT 21H
	MOV DL, 13
	INT 21H

	MOV BX, OFFSET res1 
	MOV AX, '$'
	MOV [BX+ 64], AX
	MOV DX, OFFSET res1
	MOV AH, 9
	INT 21H

;	/n
	MOV AH, 2
	MOV DL, 10
	INT 21H
	MOV DL, 13
	INT 21H
	
 PART2:
	MOV sOffset, OFFSET s + 63
	
	MOV CX, 63
	SEARCH_LOOP:
		MOV bytesLeft, CX
		
		MOV BX, sOffset
		MOV DL, [BX]
	
		CMP DL, 'A'
		JL SKIP2
			
		CMP DL, 'Z'
		JG SKIP2
		
		MOV DL, [BX - 1]
		CMP DL, '.'
		JNE SKIP2
		
			MOV dotOffset, CX
		
		SKIP2:
		
		DEC sOffset
		MOV CX, bytesLeft
	LOOP SEARCH_LOOP
	
	MOV sOffset, OFFSET s + 63
	
	MOV CX, 64
	SUB CX, dotOffset
	RES2_LOOP:
		MOV bytesLeft, CX
		
		MOV BX, sOffset
		MOV DL, [BX]
		
		CMP DL, ' '
		JE SKIP3
	
			MOV BX, res2Offset
			MOV [BX], DL
			DEC res2Offset
			
			MOV AH, 2
			INT 21H
		
		SKIP3:
		
		DEC sOffset
		MOV CX, bytesLeft
	LOOP RES2_LOOP
	
EXIT:
	MOV EAX, 4C00h				
	INT 21h					
CODE ENDS
	
END START