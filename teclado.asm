segment data public
    global key_map
    global teclado_init
    global teclado_restore
    
    key_map times 128 db 0    ; Array armazenando 1 se a tecla está pressionada, 0 se solta
    old_int9_off dw 0
    old_int9_cs  dw 0

segment code
teclado_init:
    CLI
    XOR AX, AX
    MOV ES, AX
    MOV AX, [ES:09h*4]
    MOV [old_int9_off], AX
    MOV AX, [ES:09h*4+2]
    MOV [old_int9_cs], AX
    MOV [ES:09h*4+2], CS
    MOV WORD [ES:09h*4], int9_handler
    STI
    RET

teclado_restore:
    CLI
    XOR AX, AX
    MOV ES, AX
    MOV AX, [old_int9_cs]
    MOV [ES:09h*4+2], AX
    MOV AX, [old_int9_off]
    MOV [ES:09h*4], AX
    STI
    RET

int9_handler:
    PUSH AX
    PUSH BX
    PUSH DS
    MOV AX, data
    MOV DS, AX

    IN AL, 60h              ; Lê o código Make/Break
    MOV AH, AL
    AND AL, 7Fh             ; Isola o código da tecla (0-127)
    XOR BX, BX
    MOV BL, AL

    TEST AH, 80h            ; Verifica se é Break (tecla solta)
    JNZ tecla_solta
    MOV byte [key_map + BX], 1  ; Make: Tecla pressionada
    JMP finaliza_int9

tecla_solta:
    MOV byte [key_map + BX], 0  ; Break: Tecla solta

finaliza_int9:
    IN AL, 61h
    OR AL, 80h
    OUT 61h, AL
    AND AL, 7Fh
    OUT 61h, AL
    MOV AL, 20h
    OUT 20h, AL
    POP DS
    POP BX
    POP AX
    IRET