segment data public
    extern teclado_init, teclado_restore, timer_init, timer_restore
    extern frame_flag, atualiza_mecanica
    extern desenha_cena, key_map, desenha_fundo
    extern desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit
    modo_anterior db 0
    estado_jogo   db 0  ; 0=Menu, 1=Jogando, 2=Pause, 3=Game Over

segment code
..start:
    MOV AX, data
    MOV DS, AX
    
    ; Salva modo de vídeo e entra no modo Gráfico VGA 640x480[cite: 8]
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AX, 0012h
    INT 10h

    CALL teclado_init
    CALL timer_init
    CALL desenha_fundo

game_loop:
    ; Quit (Tecla Q = 10h)
    CMP byte [key_map + 10h], 1
    JE pede_confirmacao_quit

    ; Pause (Tecla P = 19h)
    CMP byte [key_map + 19h], 1
    JE pausa_jogo

    CMP byte [frame_flag], 1    ; frame_flag sincroniza os eventos do jogo, então só vai deixar atualizar 
    JNE game_loop               ; as mecânicas e tal quando estiver setada em 1, caso contrário recomeça o loop
    MOV byte [frame_flag], 0

    CALL atualiza_mecanica
    CALL desenha_cena       ; Agora ele atualiza apenas os pixels necessários

    JMP game_loop

pede_confirmacao_quit:
    CALL desenha_menu_quit

espera_tecla_menu:
    CMP byte [key_map + 15h], 1 ; Verifica tecla Y (Make code 15h)
    JE sair_jogo
    CMP byte [key_map + 31h], 1 ; Verifica tecla N (Make code 31h)
    JE cancela_quit
    JMP espera_tecla_menu

cancela_quit:
    CALL apaga_menu_quit

espera_soltar_n:
    CMP byte [key_map + 31h], 0 ; Aguarda soltar o N para evitar double input
    JNE espera_soltar_n
    
espera_soltar_q:
    CMP byte [key_map + 10h], 0 ; Aguarda soltar o Q para não reabrir o menu
    JNE espera_soltar_q

    JMP game_loop               ; Volta pro jogo normal

pausa_jogo:
    CALL desenha_pause

espera_soltar_p1:
    CMP byte [key_map + 19h], 0 ; Aguarda o jogador soltar a tecla P que ativou o pause
    JNE espera_soltar_p1

pause_loop:
    CMP byte [key_map + 19h], 1 ; Fica em loop infinito aguardando apertar P de novo
    JNE pause_loop

    CALL apaga_pause            ; Limpa o símbolo da tela para não deixar rastro

espera_soltar_p2:
    CMP byte [key_map + 19h], 0 ; Aguarda soltar o P antes de voltar a mover os personagens
    JNE espera_soltar_p2

    JMP game_loop               ; Retorna ao jogo exatamente como estava
    
sair_jogo:
    CALL timer_restore
    CALL teclado_restore
    
    ; Restaura modo de vídeo
    MOV AH, 00h
    MOV AL, [modo_anterior]
    INT 10h
    
    MOV AX, 4C00h
    INT 21h

segment stack stack
    resb 256
stacktop: