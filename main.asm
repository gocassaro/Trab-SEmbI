segment data public
    extern teclado_init, teclado_restore, timer_init, timer_restore
    extern frame_flag, atualiza_mecanica
    extern desenha_cena, key_map, desenha_fundo
    extern desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit
    extern color_map, index_p1, index_p2, cor_p1, cor_p2
    modo_anterior db 0
    estado_jogo   db 0  ; 0=Menu, 1=Jogando, 2=Pause, 3=Game Over

segment code
..start:
    MOV AX, data
    MOV DS, AX
    
    ; Salva modo de vídeo e entra no modo Gráfico VGA 640x480
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AX, 0012h
    INT 10h

    CALL teclado_init
    CALL timer_init
    CALL desenha_fundo

select_loop:
    CMP byte [key_map + 10h], 1 ; Tecla Q para sair direto do menu
    JNE renderiza_selecao
    JMP pede_confirmacao_quit

renderiza_selecao:
    ; Sincronizador de frames (18.2 Hz)
    CMP byte [frame_flag], 1
    JNE select_loop
    MOV byte [frame_flag], 0

    CALL desenha_cena

check_select_p1:
select_up_p1:
    CMP byte [key_map + 11h], 1 ; verifica se a tecla w foi apertada
    JNE select_down_p1          ; caso não tenha sido pula para a verificaçao da tecla 's'
    SUB byte[index_p1], 1       ; caso a tecla w tenha sido apertada subtrai 1 do index da cor de p1 
    CMP byte[index_p1], -1      ; verifica se o index eh -1
    JNE check_select_p2          
    MOV byte[index_p1], 15      ; caso seja atribui 15 ao index da cor de p1 (shift circular)
    JMP check_select_p2         ; impede de verificar w e s pressionados ao mesmo tempo (prioriza w)
select_down_p1:
    CMP byte [key_map + 1Fh], 1 ; verifica se a tecla s foi apertada
    JNE check_select_p2         ; caso não tenha sido pula para a verificaçao da tecla a atribuição de cores
    ADD byte[index_p1], 1       ; caso a tecla w tenha sido apertada subtrai 1 do index da cor de p1 
    CMP byte[index_p1], 16      ; verifica se o index eh 15
    JNE check_select_p2          
    MOV byte[index_p1], 0       ; caso seja atribui 0 ao index da cor de p1 (shift circular)

check_select_p2:
select_up_p2:
    CMP byte [key_map + 48h], 1 ; Verifica se a seta para Cima foi apertada
    JNE select_down_p2          ; Se não foi, pula para a verificação da seta para Baixo
    SUB byte [index_p2], 1      ; Subtrai 1 do índice da cor de P2
    CMP byte [index_p2], -1     ; Verifica se deu underflow (-1 / 0xFF)
    JNE atribui_cores
    MOV byte [index_p2], 15     ; Shift circular: atribui 15 ao índice de P2
    JMP atribui_cores
    
select_down_p2:
    CMP byte [key_map + 50h], 1 ; Verifica se a seta para Baixo foi apertada
    JNE atribui_cores           ; Se não foi, avança para a atribuição de cores
    ADD byte [index_p2], 1      ; Adiciona 1 ao índice da cor de P2
    CMP byte [index_p2], 16     ; Verifica se ultrapassou a última cor (15)
    JNE atribui_cores
    MOV byte [index_p2], 0      ; Shift circular: atribui 0 ao índice de P2

atribui_cores:
    ; Aplica a cor do P1
    XOR BX, BX
    MOV BL, byte [index_p1]
    MOV AL, byte [color_map + BX]
    MOV byte [cor_p1], AL 
    
    ; Aplica a cor do P2
    XOR BX, BX
    MOV BL, byte [index_p2]
    MOV AL, byte [color_map + BX]
    MOV byte [cor_p2], AL

    ; Tecla ENTER (Make code 1Ch) confirma a seleção e inicia a partida
    CMP byte [key_map + 1Ch], 1
    JE game_loop

    JMP select_loop

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