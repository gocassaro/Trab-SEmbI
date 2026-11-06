segment data public
    extern teclado_init, teclado_restore, timer_init, timer_restore
    extern frame_flag, atualiza_mecanica
    extern desenha_cena, key_map, desenha_fundo
    extern desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit
    extern color_map, index_p1, index_p2, cor_p1, cor_p2
    extern p1_hp, p2_hp, p1_estado, p2_estado, p1_estado_antigo, p2_estado_antigo
    extern p1_x, p1_y, p2_x, p2_y, p1_x_antigo, p1_y_antigo, p2_x_antigo, p2_y_antigo

    modo_anterior db 0
    estado_jogo   db 0  ; 0=Menu, 1=Jogando, 2=Pause, 3=Game Over
    p1_wins       db 0  ; quantidade de rounds vencidos por p1
    p2_wins       db 0  ; quantidade de rounds vencidos por p2
    p1_knockout_msg db  'PLAYER 1 VENCEU O ROUND';23 caracteres 
    p2_knockout_msg db  'PLAYER 2 VENCEU O ROUND'
    p1_win_msg      db  'PLAYER 1 VENCEU'; 15 caracteres
    p2_win_msg      db  'PLAYER 2 VENCEU'
    round_msg       db  'ROUND ' ; 6 caracteres
    current_round   db  1 ; primeiro round
    vel             dw  5000;
    cor             db  0

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
    JE novo_round

    JMP select_loop

novo_round:
    MOV CX, 6                
    MOV BX, 0                
    MOV DH, 12               
    MOV DL, 35               
    MOV byte[cor], 15        

imprime_texto_round:
    CALL cursor              
    MOV AL, [BX+round_msg]   
    CALL caracter            
    
    INC BX
    INC DL                   
    LOOP imprime_texto_round

    CALL cursor              ; Atualiza o cursor para a posição logo após o espaço[cite: 1, 7]
    
    MOV AL, [current_round]
    ADD AL, '0'              ; Converte o número para o caractere ASCII ('1') somando 30h
    
    CALL caracter

    CALL delay

    MOV CX, 6                
    MOV BX, 0                
    MOV DH, 12               
    MOV DL, 35               
    MOV byte[cor], 0        

apaga_texto_round:
    CALL cursor              
    MOV AL, [BX+round_msg]   
    CALL caracter            
    
    INC BX
    INC DL                   
    LOOP apaga_texto_round

    CALL cursor              ; Atualiza o cursor para a posição logo após o espaço[cite: 1, 7]
    
    MOV AL, [current_round]
    ADD AL, '0'              ; Converte o número para o caractere ASCII ('1') somando 30h
    
    CALL caracter


game_loop:
    ; Quit (Tecla Q = 10h)
    CMP byte [key_map + 10h], 1
    JE pede_confirmacao_quit

check_p1_knockout:
    CMP byte[p2_hp], 0          ; verifica se a vida de p2 chegou a 0
    JNE check_p2_knockout       
    JMP p1_knockout             ; pula para a função de vencimento de round do p1

check_p2_knockout:
    CMP byte[p1_hp], 0          ; verifica se a vida de p1 chegou a 0
    JNE check_pause
    JMP  p2_knockout

check_pause:
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
    JNE verifica_tecla_n
    JMP sair_jogo
verifica_tecla_n:
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

p1_knockout:
    INC byte[p1_wins]
    CMP byte[p1_wins], 2
    JNE prepara_imprime_p1_knockout
    JMP vitoria_p1

prepara_imprime_p1_knockout:
    MOV CX, 23               ; Define o tamanho exato da nova string
    MOV BX, 0                ; Inicializa o índice do caractere
    MOV DH, 14               ; Define a linha no meio da tela (0 a 29)
    MOV DL, 28               ; Define a coluna centralizada (0 a 79)
    MOV byte[cor], 15

imprime_p1_knockout:
    CALL cursor
    MOV  AL, [BX+p1_knockout_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP imprime_p1_knockout

    CALL delay

    MOV CX, 23               
    MOV BX, 0                
    MOV DH, 14               
    MOV DL, 28              
    MOV byte[cor], 0

apaga_p1_knockout_msg:
    CALL cursor
    MOV  AL, [BX+p1_knockout_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP apaga_p1_knockout_msg

    JMP reinicia_posicoes

p2_knockout:
    INC byte[p2_wins]
    CMP byte[p2_wins], 2
    JNE prepara_imprime_p2_knockout
    JMP vitoria_p2

prepara_imprime_p2_knockout:
    MOV CX, 23              
    MOV BX, 0                
    MOV DH, 14               
    MOV DL, 28              
    MOV byte[cor], 15

imprime_p2_knockout:
    CALL cursor
    MOV  AL, [BX+p2_knockout_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP imprime_p2_knockout

    CALL delay

    MOV CX, 23               
    MOV BX, 0                
    MOV DH, 14               
    MOV DL, 28              
    MOV byte[cor], 0

apaga_p2_knockout_msg:
    CALL cursor
    MOV  AL, [BX+p2_knockout_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP apaga_p2_knockout_msg

reinicia_posicoes:
    INC byte[current_round]
    MOV BX, word[p1_x]
    MOV word[p1_x_antigo], BX
    MOV word[p1_x], 100
    MOV BX, word[p1_y]
    MOV word[p1_y_antigo], BX
    MOV word[p1_y], 80

    MOV BX, word[p2_x]
    MOV word[p2_x_antigo], BX
    MOV word[p2_x], 500
    MOV BX, word[p2_y]
    MOV word[p2_y_antigo], BX
    MOV word[p2_y], 80

reinicia_estados:
    MOV BX, word[p1_estado]
    MOV word[p1_estado_antigo], BX
    MOV word[p1_estado], 0
    MOV BX, word[p2_estado]
    MOV word[p2_estado_antigo], BX
    MOV word[p2_estado], 0

reinicia_hps:
    MOV byte[p1_hp], 10
    MOV byte[p2_hp], 10

    CALL desenha_cena
    JMP novo_round

delay:
		MOV		CX, word[vel];
del2:
		PUSH	CX
		MOV 	CX, 0800h
del1:
		LOOP	del1
		POP		CX
		LOOP	del2
		RET
    
sair_jogo:
    CALL timer_restore
    CALL teclado_restore
    
    ; Restaura modo de vídeo
    MOV AH, 00h
    MOV AL, [modo_anterior]
    INT 10h
    
    MOV AX, 4C00h
    INT 21h

;função cursor
; Parametros:
; 	DH = linha (0-29) e  DL = coluna  (0-79)
cursor:
		PUSHf
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	BP
		MOV     AH,2
		MOV     BH,0
		INT     10h
		POP		BP
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		RET
;-----------------------------------------------------------------------------
;função caracter escrito na posição do cursor
; Parametros:
; 	AL = caracter a ser escrito
; 	cor definida na variavel cor
caracter:
		PUSHf
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	BP
    	MOV     AH,9
    	MOV     BH,0
    	MOV     CX,1
   		MOV     bl,[cor]
    	INT     10h
		POP		BP
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		RET

vitoria_p1:
    MOV CX, 15               
    MOV BX, 0                
    MOV DH, 14               
    MOV DL, 28               
    MOV byte[cor], 15

imprime_p1_win:
    CALL cursor
    MOV  AL, [BX+p1_win_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP imprime_p1_win

    CALL delay

    JMP sair_jogo

vitoria_p2:
    MOV CX, 15               
    MOV BX, 0                
    MOV DH, 14               
    MOV DL, 28               
    MOV byte[cor], 15

imprime_p2_win:
    CALL cursor
    MOV  AL, [BX+p2_win_msg]
    CALL caracter

    INC BX
    INC DL
    LOOP imprime_p2_win

    CALL delay

    JMP sair_jogo

segment stack stack
    resb 256
stacktop: