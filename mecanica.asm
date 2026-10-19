segment data public
    global p1_x, p1_y, p1_hp, p1_estado
    global p2_x, p2_y, p2_hp, p2_estado
    global p1_x_antigo, p1_y_antigo
    global p2_x_antigo, p2_y_antigo
    global atualiza_mecanica
    extern key_map
    
    ; === ESTADOS DOS PLAYERS:  PARADO(0), ANDANDO ESQUERDA(1), ANDANDO DIREITA(1), AGACHANDO(2), 
    ;                           PULANDO(3), ATACANDO SOCO(4), ATACANDO CHUTE(5);  

    p1_x      dw 100
    p1_y      dw 300
    p1_x_antigo dw 100
    p1_y_antigo dw 300
    p1_hp     db 10
    p1_estado db 0
    p1_timer  db 0       ; Timer para duração do soco/chute

    p2_x      dw 500
    p2_y      dw 300
    p2_x_antigo dw 500
    p2_y_antigo dw 300
    p2_hp     db 10
    p2_estado db 0
    p2_timer  db 0

segment code
atualiza_mecanica:
    ; === JOGADOR 1 (W=11h, A=1Eh, S=1Fh, D=20h, (Chute)R=13h, (Soco)T=14h) ===
    MOV byte [p1_estado], 0  ; Default: Parado
    
    ; Defesa/Esquiva: Agachar
    CMP byte [key_map + 1Fh], 1 ; verifica se a tecla de agachar foi pressionada
    JNE check_p1_jump           ; caso nao tenha sido salta para a proxima verificacao
    MOV byte [p1_estado], 2     ; caso contrario, atribui o estado de agachado ao P1
    JMP check_p1_attacks        ; 
    
check_p1_jump:
    ; Defesa/Esquiva: Pular
    CMP byte [key_map + 11h], 1
    JNE check_p1_left
    MOV byte [p1_estado], 3
    JMP check_p1_attacks

check_p1_left:
    CMP byte [key_map + 1Eh], 1 ; Esquerda
    JNE check_p1_right
    SUB word [p1_x], 5
    MOV byte [p1_estado], 1

check_p1_right:
    CMP byte [key_map + 20h], 1 ; Direita
    JNE check_p1_attacks
    ADD word [p1_x], 5
    MOV byte [p1_estado], 1

check_p1_attacks:               ; verificar os ataques
check_punch_p1:                 ; verifica o soco de P1
    ; Soco (T=14h)
    CMP byte [key_map + 14h], 1 ; compara a tecla de soco com 1
    JNE check_kick_p1           ; se o soco nao foi dado pula para a verificacao do chute
    MOV byte [p1_estado], 4     ; caso contrario, atribui o estado de ATACANDO SOCO a P1
    CALL verifica_colisao_soco_p1    ; pula para a verificacao de acerto do soco
    CALL check_p2               ; apos isso, pula para a verificacao de P2
check_kick_p1:                  ; verifica o chute de P1
    ; chute (R=13h)
    CMP byte [key_map + 13h], 1 ; compara a tecla de chute com 1
    JNE check_p2                ; se o chute nao foi dado, pula para a verificacao de p2
    MOV byte [p1_estado], 4     ; caso o contrario, atribui o estado de ATACANDO CHUTE a P1
    CALL verifica_colisao_chute_p1    ; verifica se o chute acertou

; Lógica espelhada para P2 (Setas Cima=48h, Esquerda=4Bh, Baixo=50h, Direita=4Dh, (Chute)N=31h, (Soco)M=32h)
check_p2:
    MOV byte [p2_estado], 0     ; Default: Parado
    
    ; Defesa/Esquiva: Agachar
    CMP byte [key_map + 50h], 1
    JNE check_p2_jump
    MOV byte [p2_estado], 2
    JMP check_p2_attacks
    
check_p2_jump:
    ; Defesa/Esquiva: Pular
    CMP byte [key_map + 48h], 1
    JNE check_p2_move
    MOV byte [p2_estado], 3
    JMP check_p2_attacks

check_p2_move:
    CMP byte [key_map + 4Bh], 1 ; Seta Esquerda
    JNE check_p2_right
    SUB word [p2_x], 5
    MOV byte [p2_estado], 1
check_p2_right:
    CMP byte [key_map + 4Dh], 1 ; Seta Direita
    JNE check_p2_attacks
    ADD word [p2_x], 5
    MOV byte [p2_estado], 1

check_p2_attacks:               ; verificar os ataques
check_punch_p2:                 ; verifica o soco de P2
    ; Soco (M=32h)
    CMP byte [key_map + 32h], 1 ; compara a tecla de soco com 1
    JNE check_kick_p2           ; se o soco nao foi dado pula para a verificacao do chute
    MOV byte [p2_estado], 4     ; caso contrario, atribui o estado de ATACANDO SOCO a P2
    CALL verifica_colisao_soco_p2    ; pula para a verificacao de acerto do soco
    CALL fim_mecanica           ; apos isso, pula para a verificacao de P2
check_kick_p2:                  ; verifica o chute de P1
    ; chute (N=31h)
    CMP byte [key_map + 31h], 1 ; compara a tecla de chute com 1
    JNE fim_mecanica            ; se o chute nao foi dado, pula para a o fim da mecanica
    MOV byte [p2_estado], 4     ; caso o contrario, atribui o estado de ATACANDO CHUTE a P1
    CALL verifica_colisao_p2    ; verifica se o chute acertou

fim_mecanica:
    RET

; === FUNÇÃO DE COLISÃO DO JOGADOR 1 ===
verifica_colisao_p1:
verifica_colisao_soco_p1:
    CMP byte [p2_estado], 2 ; se P2 estiver agachado, ele se defende do soco
    JE sem_dano_p1          ; assume que p1 nao infligiu dano
    CALL calc_dist_p1       ; caso P2 nao esteja agachado, verifica a distancia
verifica_colisao_chute_p1:  ; 
    CMP byte [p2_estado], 3 ; se P2 estiver pulando, ele se defende do chute
    JE sem_dano_p1

calc_dist_p1: 
    ; Calcula distância absoluta |P1_X - P2_X|
    MOV AX, [p1_x]
    SUB AX, [p2_x]
    JNS check_dist_p1       ; Se o resultado não for negativo (Jump if Not Sign), pula
    NEG AX                  ; Inverte o sinal para virar positivo
check_dist_p1:
    CMP AX, 60              ; Distância máxima do soco
    JG sem_dano_p1
    
    CMP byte [p2_hp], 0     ; Verifica se a vida já está zerada
    JE sem_dano_p1          ; Se sim, não subtrai
    DEC byte [p2_hp]        ; Dano aplicado
sem_dano_p1:
    RET

; === FUNÇÃO DE COLISÃO DO JOGADOR 2 ===
verifica_colisao_p2:
verifica_colisao_soco_p2:
    CMP byte [p1_estado], 2 ; se P1 estiver agachado, ele se defende do soco
    JE sem_dano_p2          ; assume que p2 nao infligiu dano
    CALL calc_dist_p2       ; caso P1 nao esteja agachado, verifica a distancia
verifica_colisao_chute_p2:  ; 
    CMP byte [p1_estado], 3 ; se P1 estiver pulando, ele se defende do chute
    JE sem_dano_p2
    
calc_dist_p2:
    ; Calcula distância absoluta |P2_X - P1_X|
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    JNS check_dist_p2
    NEG AX
check_dist_p2:
    CMP AX, 60              ; Distância máxima do soco
    JG sem_dano_p2
    
    CMP byte [p1_hp], 0     ; Verifica se a vida já está zerada
    JE sem_dano_p2          ; Se sim, não subtrai
    DEC byte [p1_hp]        ; Dano aplicado
sem_dano_p2:
    RET