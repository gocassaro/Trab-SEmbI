segment data public
    global timer_init
    global timer_restore
    global tempo_round
    global frame_flag

    old_int8_off dw 0
    old_int8_cs  dw 0
    tique        db 0
    tempo_round  dw 180      ; 3 minutos = 180 segundos
    frame_flag   db 0        ; Sincroniza a lógica principal

segment code
timer_init:
    CLI
    XOR AX, AX
    MOV ES, AX
    MOV AX, [ES:08h*4]
    MOV [old_int8_off], AX
    MOV AX, [ES:08h*4+2]
    MOV [old_int8_cs], AX
    MOV [ES:08h*4+2], CS
    MOV WORD [ES:08h*4], int8_handler
    STI
    RET

timer_restore:
    CLI
    XOR AX, AX
    MOV ES, AX
    MOV AX, [old_int8_cs]
    MOV [ES:08h*4+2], AX
    MOV AX, [old_int8_off]
    MOV [ES:08h*4], AX
    STI
    RET

int8_handler:
    PUSH AX
    PUSH DS
    MOV AX, data
    MOV DS, AX

    MOV byte [frame_flag], 1 ; Avisa o loop principal para atualizar o jogo
    
    INC byte [tique]
    CMP byte [tique], 18     ; ~1 segundo
    JB fim_int8
    MOV byte [tique], 0
    
    CMP word [tempo_round], 0
    JE fim_int8
    DEC word [tempo_round]   ; Decrementa o tempo do round

fim_int8:
    MOV AL, 20h
    OUT 20h, AL
    POP DS
    POP AX
    IRET