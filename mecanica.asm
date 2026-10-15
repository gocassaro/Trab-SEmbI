segment data public
    global p1_x, p1_y, p1_hp, p1_estado
    global p2_x, p2_y, p2_hp, p2_estado
    global atualiza_mecanica
    extern key_map
    
    p1_x      dw 100
    p1_y      dw 300
    p1_hp     db 10
    p1_estado db 0
    p1_timer  db 0       ; Timer para duração do soco/chute

    p2_x      dw 500
    p2_y      dw 300
    p2_hp     db 10
    p2_estado db 0
    p2_timer  db 0

segment code
atualiza_mecanica:
    ; === JOGADOR 1 (W=11h, A=1Eh, S=1Fh, D=20h, R=13h, T=14h) ===
    MOV byte [p1_estado], 0  ; Default: Parado
    
    ; Defesa/Esquiva: Agachar
    CMP byte [key_map + 1Fh], 1
    JNE check_p1_jump
    MOV byte [p1_estado], 2
    JMP check_p1_attacks
    
check_p1_jump:
    ; Defesa/Esquiva: Pular
    CMP byte [key_map + 11h], 1
    JNE check_p1_move
    MOV byte [p1_estado], 3
    JMP check_p1_attacks

check_p1_move:
    CMP byte [key_map + 1Eh], 1 ; A (Esquerda)
    JNE check_p1_right
    SUB word [p1_x], 5
    MOV byte [p1_estado], 1
check_p1_right:
    CMP byte [key_map + 20h], 1 ; D (Direita)
    JNE check_p1_attacks
    ADD word [p1_x], 5
    MOV byte [p1_estado], 1

check_p1_attacks:
    ; Soco (T)
    CMP byte [key_map + 14h], 1
    JNE check_p2
    MOV byte [p1_estado], 4
    CALL verifica_colisao_p1

check_p2:
    ; Lógica espelhada para P2 (Setas 48h, 4Bh, 50h, 4Dh, M=32h, N=31h)
    ; ... (Para economizar espaço, repita a estrutura acima para P2 atualizando p2_estado e p2_x)
    
    RET

verifica_colisao_p1:
    ; Se P2 estiver agachado (2) ou pulando (3), ele se defende (esquiva) do soco
    CMP byte [p2_estado], 2
    JE sem_dano
    CMP byte [p2_estado], 3
    JE sem_dano
    
    ; Verifica distância X (Alcance do soco = 60 pixels)
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 60
    JG sem_dano
    
    ; Reduz HP se estiver perto e sem defesa
    DEC byte [p2_hp]
sem_dano:
    RET