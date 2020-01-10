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
	array 	DD 	-2, 5, -1, 0, 18, -6, 5, 6, -3, -20, -17, 7
	result  	DD 	10 DUP(0)
	temp		DD 	0
	min		DD 	0
	max		DD 	0
DATA ENDS

CODE SEGMENT PARA PUBLIC 'code'
	.486
	ASSUME CS: CODE, DS: DATA
	
START:
	MOV	EAX, DATA				
	MOV	DS, EAX	

 ; Part 2
	MOV EBX, array[0]
	MOV min, EBX
	MOV EBX, array[(N - 1) * 4]
	MOV max, EBX
	
	MOV ESI, 4
	MOV EDI, 0
	
LOOP3:
		MOV EBX, array[ESI]
	
		CMP EBX, min
		JL INSERT
	
		CMP EBX, max
		JG INSERT
		
		JMP NOINSERT
INSERT:
		MOV result[EDI], EBX
		ADD EDI, 4
NOINSERT:
		ADD ESI, 4
		CMP ESI, (N - 1) * 4
	JL LOOP3	
     	
 ; Part 1
	MOV EAX, 0
LOOP1:
		MOV ECX, 0
LOOP2:
			MOV EBX, OFFSET array
			MOV ESI, ECX
			ADD ESI, ESI
			ADD ESI, ESI
			MOV EDX, [EBX + ESI] ; EDX = A[I]
			
			ADD ESI, 4
			MOV EBX, [EBX + ESI] ; EBX = A[I + 1]
			
			CMP EDX, EBX			
			JLE NOSWAP
			
			CMP EDX, 0
			JLE NOSWAP
			
			MOV temp, EBX
			MOV EBX, OFFSET array
			MOV [EBX + ESI], EDX
			
			SUB ESI, 4
			MOV EDX, temp
			MOV [EBX + ESI], EDX
NOSWAP:
			ADD ECX, 1
			CMP ECX, N - 1
		JL LOOP2
		
		ADD EAX, 1
		CMP EAX, N
	JL LOOP1
	
	


EXIT:
	MOV	EAX, 4C00h				
	INT 21h					
CODE ENDS
	
END START