; Вариант 8. Перехватывается прерывание 09H (клавиатура), горячая клавиша: <Shift>+<Ctrl>+<O>.
; Действия резидентной части программы: блокировка ввода с клавиатуры до повторного нажатия "горячей" клави​ши,
; вывод сообщения о блокировке клавиатуры.

.model tiny
.code
org 100h

print MACRO string:REQ
	MOV AX, CS
	MOV DS, AX
	MOV DX, OFFSET string
	MOV AH, 09h
	INT 21h
ENDM

main:
	JMP _main
	hotkey_msg 				DB 		'Press Ctrl+Shift+O to block keyboard', '$'
	blocked_msg    			DB 		10, 13, 'Keyboard is blocked. Press Ctrl+Shift+O to unblock', '$'
	already_running_msg    	DB 		'Already running', '$'
	exit_msg  				DB 		10, 13, 'Program exit', 10, 13, '$'
	sys_handler 			DD 		0
	is_blocked				DW		0
	
	ctrl_mask   			EQU 	04h
	shift_mask   			EQU 	02h
	ctrl_shift_mask			EQU		ctrl_mask OR shift_mask
	keycode_key_up			EQU		80h
	keycode_o 				EQU 	18h
	keycode_ctrl 			EQU 	1Dh 
	keycode_shift 			EQU 	2Ah
	blocked_msg_len			EQU		51

handler PROC far uses AX CX DI SI DS ES
	IN AL, 60h
	CMP AL, keycode_o
	JNE not_hotkey		
	
	MOV AH, 02h
	INT 16h
	AND AL, ctrl_shift_mask
	CMP AL, ctrl_shift_mask
	JNE not_hotkey	
	
	MOV AX, CS:is_blocked
	CMP AX, 1
	JE uninstall
	print blocked_msg
	MOV CS:is_blocked, 1
	JMP skipSystemInterrupt

	not_hotkey:
	MOV AX, CS:is_blocked
	CMP AX, 1
	JE skipSystemInterrupt
	JMP callSystemInterrupt

uninstall:
	MOV AH, 03h
	MOV BH, 0
	INT 10h
	
	MOV AH, 0Fh
	INT 10h
	MOV AH, 03h
	INT 10h
	
	MOV AH, 02h
	SUB DL, blocked_msg_len
	INT 10h

	MOV AH, 09h
	MOV BL, 0h
	MOV CX, blocked_msg_len
	INT 10h

	MOV AX, WORD PTR CS:sys_handler[2]
	MOV DS, AX
	MOV DX, WORD PTR CS:sys_handler
	MOV AX, 2509h
	INT 21h
	MOV AX, 25FFh
	MOV DX, 0000h
	INT 21h
	PUSH ES 
	MOV ES, CS:2Ch
	MOV AH, 49h
	INT 21h
	PUSH CS
	POP ES
	MOV AH, 49h
	INT 21h
	POP ES
	PUSH DS
	print CS:exit_msg
	POP DS
	JMP skipSystemInterrupt

callSystemInterrupt:
	PUSHF
	CALL CS:sys_handler
	JMP exit
skipSystemInterrupt:
    IN AL, 61H      
    MOV AH, AL      
    OR AL, 80h      
    OUT 61H, AL     
    XCHG AH, AL     
    OUT 61H, AL
    
    MOV AL, 20H
    OUT 20H, AL
exit:
	IRET
handler ENDP
handler_end:

_main: 
	MOV AX, 35FFh
	INT 21h
	CMP BX, 00h
	JNE running
		
install:
	print hotkey_msg
		
	MOV AX, 25FFh	
	MOV DX, 01h	
	INT 21h
	MOV AH, 35h
	MOV AL, 09h
	INT 21h
	MOV WORD PTR CS:sys_handler, BX 
	MOV WORD PTR CS:sys_handler + 2, ES
	MOV AH, 25h
	MOV AL, 09h
	MOV DX, OFFSET handler
	INT 21h
	MOV DX, OFFSET handler - OFFSET handler_end
	MOV CL, 4
	SHR DX, CL
	INC DX
	MOV AX, 3100h
	INT 21h	
	
running:
	print already_running_msg
	MOV AX, 4C00h
	INT 21h
END main