segment data public
    extern teclado_init, teclado_restore, timer_init, timer_restore
    extern frame_flag, atualiza_mecanica, desenha_cena, key_map
    global update_visual
    update_visual db 1      ; Flag que indica se houve mudança visual
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

game_loop:
    ; Pause (Tecla P = 19h)[cite: 5]
    CMP byte [key_map + 10h], 1 ; Verifica tecla Q (Sair)
    JE sair_jogo

    CMP byte [frame_flag], 1    ; Verifica se o tick de 55ms passou
    JNE game_loop
    MOV byte [frame_flag], 0    ; Reseta a flag do timer

    CALL atualiza_mecanica

    ; --- INÍCIO DO LIMITADOR ---
    CMP byte [update_visual], 1 ; Verifica se a mecânica alterou algo
    JNE game_loop               ; Se não mudou, pula o desenho e espera próximo frame
    
    CALL desenha_cena           ; Se mudou, redesenha
    MOV byte [update_visual], 0 ; Abaixa a flag de desenho após repintar
    ; --- FIM DO LIMITADOR ---
    
    JMP game_loop
    
verifica_quit:
    ; Quit (Tecla Q = 10h)[cite: 4]
    CMP byte [key_map + 10h], 1
    JE sair_jogo

    ; Sincronização de FPS (só roda a lógica se a INT 8h sinalizou)
    CMP byte [frame_flag], 1
    JNE game_loop
    MOV byte [frame_flag], 0

    CALL atualiza_mecanica
    CALL desenha_cena
    
    JMP game_loop

sair_jogo:
    CALL timer_restore
    CALL teclado_restore
    
    ; Restaura modo de vídeo[cite: 9]
    MOV AH, 00h
    MOV AL, [modo_anterior]
    INT 10h
    
    MOV AX, 4C00h
    INT 21h

segment stack stack
    resb 256
stacktop: