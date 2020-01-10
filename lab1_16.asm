 ; В исходном массиве переставить элементы так, чтобы они располагались в следующем порядке: 
 ; 	4:	Все элементы исх. массива больше нуля располагаются в
 ;      порядке убывания от конца исходного массива, остальные 
 ;      элементы записываются с начала массива в естественном порядке;  

 ; Условие формирования массива результата. 
 ; Элемент исходного массива помещается в массив результата если его значение:                            
 ;	5:	Не находится в интервале заданном значениями первого и  последнего элементов исходного массива.
 
 ; Способ адресации 
 ;	1:	Обработка исходного массива: Базовая
 ;		Формирование массива результата: Индексная
 
.MODEL	small

DATA SEGMENT PARA PUBLIC 'data'
	N			EQU	12
	array 	DW 	-2, 5, -1, 0, 18, -6, 5, 6, -3, -20, -17, 7
	result  	DW 	10 DUP(0)
	temp		DW 	0
	min		DW 	0
	max		DW 	0
DATA ENDS

CODE SEGMENT PARA PUBLIC 'code'
	ASSUME CS: CODE, DS: DATA
	
START:
	MOV	AX, DATA				
	MOV	DS, AX
	
; Part 2
	MOV BX, array[0]
	MOV min, BX
	MOV BX, array[(N - 1) * 2]
	MOV max, BX
	
	MOV SI, 2
	MOV DI, 0
	
LOOP3:
		MOV BX, array[SI]
	
		CMP BX, min
		JL INSERT
	
		CMP BX, max
		JG INSERT
		
		JMP NOINSERT
INSERT:
		MOV result[DI], BX
		ADD DI, 2
NOINSERT:
		ADD SI, 2
		CMP SI, (N - 1) * 2
	JL LOOP3
	
 ; Part 1     	
	MOV AX, 0
LOOP1:
		MOV CX, 0
LOOP2:
			MOV BX, OFFSET array
			MOV SI, CX
			ADD SI, SI
			MOV DX, [BX + SI] ; DX = A[I]
			
			ADD SI, 2
			MOV BX, [BX + SI] ; BX = A[I + 1]
			
			CMP DX, BX			
			JLE NOSWAP
			
			CMP DX, 0
			JLE NOSWAP
			
			MOV temp, BX
			MOV BX, OFFSET array
			MOV [BX + SI], DX
			
			SUB SI, 2
			MOV DX, temp
			MOV [BX + SI], DX
NOSWAP:
			ADD CX, 1
			CMP CX, N - 1
		JL LOOP2
		
		ADD AX, 1
		CMP AX, N
	JL LOOP1

 
EXIT:	
	MOV	AX, 4C00h				
	INT 21h					
CODE ENDS
	
END START