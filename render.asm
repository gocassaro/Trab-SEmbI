segment data public
    global desenha_cena, desenha_fundo, desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit
    global index_p1, index_p2, cor_p1, cor_p2, color_map
	extern p1_x, p1_y, p1_hp, p1_x_antigo, p1_y_antigo, p1_estado
    extern p2_x, p2_y, p2_hp, p2_x_antigo, p2_y_antigo, p2_estado
    msg_sair db 'QUIT? Y/N', 0
    
    cor		db		branco_intenso
							; I R G B COR
    preto			equ		0	; 0 0 0 0 preto
    azul			equ		1	; 0 0 0 1 azul
    verde			equ		2	; 0 0 1 0 verde
    cyan			equ		3	; 0 0 1 1 cyan
    vermelho		equ		4	; 0 1 0 0 vermelho
    magenta			equ		5	; 0 1 0 1 magenta
    marrom			equ		6	; 0 1 1 0 marrom
    branco			equ		7	; 0 1 1 1 branco
    cinza			equ		8	; 1 0 0 0 cinza
    azul_claro		equ		9	; 1 0 0 1 azul claro
    verde_claro		equ		10	; 1 0 1 0 verde claro
    cyan_claro		equ		11	; 1 0 1 1 cyan claro
    rosa			equ		12	; 1 1 0 0 rosa
    magenta_claro	equ		13	; 1 1 0 1 magenta claro
    amarelo			equ		14	; 1 1 1 0 amarelo
    branco_intenso	equ		15	; 1 1 1 1 branco INTenso
    deltAX			dw		0
    deltay			dw		0

	; 2. Cria o vetor carregando as constantes (16 posições, índice 0 a 15)
    color_map       db      preto, azul, verde, cyan, vermelho, magenta, marrom, branco, cinza, azul_claro, verde_claro, cyan_claro, rosa, magenta_claro, amarelo, branco_intenso

    ; Variáveis para armazenar o índice escolhido pelos jogadores (ex: 1 para azul, 4 para vermelho)
    index_p1        db      1   
    index_p2        db      4   

    ; Variáveis finais das cores
    cor_p1          db      azul
    cor_p2          db      vermelho

segment code

; =========================================================
; DESENHA FUNDO: EXECUTADO APENAS 1 VEZ AO INICIAR O JOGO
; =========================================================
desenha_fundo:
    ; 1. Limpa a tela inteira (Preenche de preto)
    MOV AX, 0600h
    MOV BH, 00h
    MOV CX, 0000h
    MOV DX, 1D4Fh
    INT 10h

    ; 2. Desenha o Fundo da Barra P1 (Cinza escuro)
    MOV CX, 20          ; X inicial
    MOV DX, 20          ; Y inicial
    MOV SI, 200         ; Largura máxima
    MOV DI, 15          ; Altura
    MOV AL, 8           ; Cor: 8 (Cinza)
    CALL desenha_retangulo

    ; 3. Desenha o Fundo da Barra P2 (Cinza escuro)
    MOV CX, 420         ; X inicial (Termina no 620)
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8
    CALL desenha_retangulo
    
    RET

; =========================================================
; DESENHA CENA: EXECUTADO A CADA FRAME (18.2 Hz)
; =========================================================
desenha_cena:
    ; --- 1. APAGA OS RASTROS DO FRAME ANTERIOR ---
    ; Aumentamos a área de limpeza para 50x90 para apagar os rastros
    ; dos membros e da cabeça em movimentos rápidos sem deixar rastro.
    mov     ax, [p1_x]
    cmp     ax, [p1_x_antigo]
    jne     apaga_p1
    mov     ax, [p1_y]
    cmp     ax, [p1_y_antigo]
    je     pula_apaga_p1

    ; Apaga P1 antigo
    apaga_p1:
        MOV AX, [p1_x_antigo]
        SUB AX, 12
        MOV CX, AX                  ; X inicial
        MOV AX, [p1_y_antigo]
        ADD AX, 55                  ; Topo do sprite no plano cartesiano
        MOV DX, 479
        SUB DX, AX                  ; Converte Y cartesiano para coordenada de tela
        MOV SI, 50                  
        MOV DI, 90                  
        MOV AL, 0           
        CALL desenha_retangulo

    pula_apaga_p1:

        mov     ax, [p2_x]
        cmp     ax, [p2_x_antigo]
        jne     apaga_p2
        mov     ax, [p2_y]
        cmp     ax, [p2_y_antigo]
        je     pula_apaga_p2
    
    ; Apaga P2 antigo    
    apaga_p2:
        MOV AX, [p2_x_antigo]
        SUB AX, 15
        MOV CX, AX
        MOV AX, [p2_y_antigo]
        ADD AX, 55
        MOV DX, 479
        SUB DX, AX
        MOV SI, 50
        MOV DI, 90
        MOV AL, 0
        CALL desenha_retangulo

    pula_apaga_p2:    
    ;Desenha chão
    MOV     AX, 0
    PUSH    AX
    MOV     AX, 0
    PUSH    AX
    MOV     AX, 0
    PUSH    AX
    MOV     AX, 45
    PUSH    AX
    MOV     AX, 640
    PUSH    AX
    MOV     byte[cor], verde_claro
    call    desenha_retangulo2

    ; =========================================================================
    ; DESENHO DO PLAYER 1 (Original - Dinâmico baseado em p1_x e p1_y)
    ; =========================================================================
		
		; cabelo P1 (X = p1_x + 4, Y = p1_y + 42)
		MOV		AX, [p1_x]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 42
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 46
		PUSH	AX
		mov		ax, 20
		push	ax
		mov		byte[cor], preto
		call	desenha_retangulo2
		
		; faixa na cabeça P1 (X = p1_x + 3, Y = p1_y + 38)
		MOV		AX, [p1_x]
		ADD		AX, 3
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 38
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 3
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 41
		PUSH	AX
		mov		ax, 22
		push	ax
		MOV		BL, byte[cor_p1]
		mov		byte[cor], BL
		call	desenha_retangulo2

		; cabeça P1 (X = p1_x + 4, Y = p1_y + 25)
		MOV		AX, [p1_x]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 25
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 37
		PUSH	AX
		mov		ax, 20
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2

		; olho P1 (X = p1_x + 18, Y = p1_y + 32)
		MOV		AX, [p1_x]
		ADD		AX, 18
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 32
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 18
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 35
		PUSH	AX
		mov		ax, 3
		push	ax
		mov		byte[cor], preto
		call	desenha_retangulo2
		
		; peito P1 (X = p1_x, Y = p1_y) -> Ponto de ancoragem base
		MOV		AX, [p1_x]
		PUSH	AX
		MOV		AX, [p1_y]
		PUSH	AX
		MOV		AX, [p1_x]
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 23
		PUSH	AX
		mov		ax, 26
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		; pernas P1 (Esquerda: X = p1_x - 2, Y = p1_y - 28 | Direita: X = p1_x + 18, Y = p1_y - 28)
		MOV		AX, [p1_x]
		SUB		AX, 2
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 28
		PUSH	AX
		MOV		AX, [p1_x]
		SUB		AX, 2
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 5
		PUSH	AX
		mov		ax, 11
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		MOV		AX, [p1_x]
		ADD		AX, 18
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 28
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 18
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 5
		PUSH	AX
		mov		ax, 10
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2

		; faixa cintura P1 (X = p1_x - 1, Y = p1_y - 6)
		MOV		AX, [p1_x]
		SUB		AX, 1
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p1_x]
		SUB		AX, 1
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 1
		PUSH	AX
		mov		ax, 28
		push	ax
		MOV 	BL, byte[cor_p1]
		mov		byte[cor], BL
		call	desenha_retangulo2
		
		; pés P1 (Esquerdo: X = p1_x - 6, Y = p1_y - 33 | Direito: X = p1_x + 22, Y = p1_y - 33)
		MOV		AX, [p1_x]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 33
		PUSH	AX
		MOV		AX, [p1_x]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 27
		PUSH	AX
		mov		ax, 12
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		MOV		AX, [p1_x]
		ADD		AX, 22
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 33
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 22
		PUSH	AX
		MOV		AX, [p1_y]
		SUB		AX, 27
		PUSH	AX
		mov		ax, 10
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		; braços P1 (X = p1_x + 26, Y = p1_y + 11)
		MOV		AX, [p1_x]
		ADD		AX, 26
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 11
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 26
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 18
		PUSH	AX
		mov		ax, 7
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		; mãos P1 (Esquerda: X = p1_x - 4, Y = p1_y + 4 | Direita: X = p1_x + 30, Y = p1_y + 13)
		MOV		AX, [p1_x]
		SUB		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p1_x]
		SUB		AX, 4
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 10
		PUSH	AX
		mov		ax, 7
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		MOV		AX, [p1_x]
		ADD		AX, 30
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 13
		PUSH	AX
		MOV		AX, [p1_x]
		ADD		AX, 30
		PUSH	AX
		MOV		AX, [p1_y]
		ADD		AX, 20
		PUSH	AX
		mov		ax, 8
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2


    ; =========================================================================
    ; DESENHO DO PLAYER 2 (Invertido e Dinâmico baseado em p2_x e p2_y)
    ; =========================================================================
		
		; cabelo P2 (X = p2_x + 2, Y = p2_y + 42)
		MOV		AX, [p2_x]
		ADD		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 42
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 46
		PUSH	AX
		mov		ax, 20
		push	ax
		mov		byte[cor], preto
		call	desenha_retangulo2
		
		; faixa na cabeça P2 (X = p2_x + 1, Y = p2_y + 38)
		MOV		AX, [p2_x]
		ADD		AX, 1
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 38
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 1
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 41
		PUSH	AX
		mov		ax, 22
		push	ax
		MOV		BL, byte[cor_p2]
		mov		byte[cor], BL
		call	desenha_retangulo2

		; cabeça P2 (X = p2_x + 2, Y = p2_y + 25)
		MOV		AX, [p2_x]
		ADD		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 25
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 37
		PUSH	AX
		mov		ax, 20
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		; olho P2 (X = p2_x + 5, Y = p2_y + 32 | Olhando para a esquerda)
		MOV		AX, [p2_x]
		ADD		AX, 5
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 32
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 5
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 35
		PUSH	AX
		mov		ax, 3
		push	ax
		mov		byte[cor], preto
		call	desenha_retangulo2
		
		; peito P2 (X = p2_x, Y = p2_y)
		MOV		AX, [p2_x]
		PUSH	AX
		MOV		AX, [p2_y]
		PUSH	AX
		MOV		AX, [p2_x]
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 23
		PUSH	AX
		mov		ax, 26
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		; pernas P2 (Esquerda: X = p2_x + 17, Y = p2_y - 28 | Direita: X = p2_x - 2, Y = p2_y - 28)
		MOV		AX, [p2_x]
		ADD		AX, 17
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 28
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 17
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 5
		PUSH	AX
		mov		ax, 11
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		MOV		AX, [p2_x]
		sub		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 28
		PUSH	AX
		MOV		AX, [p2_x]
		sub		AX, 2
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 5
		PUSH	AX
		mov		ax, 10
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2

		; faixa cintura P2 (X = p2_x - 1, Y = p2_y - 6)
		MOV		AX, [p2_x]
		sub		AX, 1
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p2_x]
		sub		AX, 1
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 1
		PUSH	AX
		mov		ax, 28
		push	ax
		MOV     BL, byte[cor_p2]
		mov		byte[cor], BL
		call	desenha_retangulo2
		
		; pés P2 (Esquerdo: X = p2_x + 20, Y = p2_y - 33 | Direito: X = p2_x - 6, Y = p2_y - 33)
		MOV		AX, [p2_x]
		ADD		AX, 20
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 33
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 20
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 27
		PUSH	AX
		mov		ax, 12
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		MOV		AX, [p2_x]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 33
		PUSH	AX
		MOV		AX, [p2_x]
		SUB		AX, 6
		PUSH	AX
		MOV		AX, [p2_y]
		SUB		AX, 27
		PUSH	AX
		mov		ax, 10
		push	ax
		mov		byte[cor], marrom
		call	desenha_retangulo2
		
		; braços P2 (X = p2_x - 7, Y = p2_y + 11)
		MOV		AX, [p2_x]
		SUB		AX, 7
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 11
		PUSH	AX
		MOV		AX, [p2_x]
		SUB		AX, 7
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 18
		PUSH	AX
		mov		ax, 7
		push	ax
		mov		byte[cor], branco_intenso
		call	desenha_retangulo2
		
		; mãos P2 (Esquerda: X = p2_x + 23, Y = p2_y + 4 | Direita: X = p2_x - 12, Y = p2_y + 13)
		MOV		AX, [p2_x]
		ADD		AX, 23
		PUSH	AX
		MOV		AX, [p2_y]
		ADD		AX, 4
		PUSH	AX
		MOV		AX, [p2_x]
		ADD		AX, 23
		PUSH	AX
		MOV		AX, [p2_y]
        ADD		AX, 10
        PUSH	AX
        mov		ax, 7
        push	ax
        mov		byte[cor], marrom
        call	desenha_retangulo2
        MOV		AX, [p2_x]
        SUB		AX, 12
        PUSH	AX
        MOV		AX, [p2_y]
        ADD		AX, 13
        PUSH	AX
        MOV		AX, [p2_x]
        SUB		AX, 12
        PUSH	AX
        MOV		AX, [p2_y]
        ADD		AX, 20
        PUSH	AX
        mov		ax, 8
        push	ax
        mov		byte[cor], marrom
        call	desenha_retangulo2

    ; --- 3. ATUALIZA AS BARRAS DE VIDA (igual ao seu código anterior) ---
    MOV CX, 20
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo
    
    CMP byte [p1_hp], 0
    JE atualiza_hp2     
    MOV AL, [p1_hp]
    XOR AH, AH          
    MOV BX, 20
    MUL BX              
    MOV SI, AX          
    MOV CX, 20          
    MOV DX, 20          
    MOV DI, 15          
    MOV AL, 14          
    CALL desenha_retangulo

atualiza_hp2:
    MOV CX, 420
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo

    CMP byte [p2_hp], 0
    JE fim_desenho      
    MOV AL, [p2_hp]
    XOR AH, AH
    MOV BX, 20
    MUL BX              
    MOV SI, AX          
    MOV CX, 620         
    SUB CX, AX          
    MOV DX, 20          
    MOV DI, 15          
    MOV AL, 14          
    CALL desenha_retangulo

fim_desenho:
    RET

; =========================================================
; FUNÇÃO AUXILIAR: DESENHA RETÂNGULO GENÉRICO
; Parâmetros de Entrada:
; CX = X Inicial | DX = Y Inicial
; SI = Largura   | DI = Altura
; AL = Cor (0 a 15)
; =========================================================
desenha_retangulo:
    CMP SI, 0
    JE fim_retangulo
    CMP DI, 0
    JE fim_retangulo

    ; Salva o contexto dos registradores para não corromper o chamador
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BX
    
    MOV BX, DI          ; BX será o contador de linhas (Altura)
linha:
    PUSH CX             ; Salva a posição X original da linha
    PUSH BX             ; Salva a altura restante
    
    MOV BX, SI          ; BX será o contador de colunas (Largura)
coluna:
    MOV AH, 0Ch         ; Função de escrever pixel da INT 10h
    PUSH BX             ; Protege o contador de largura da INT 10h
    MOV BH, 0           ; Página de vídeo 0
    INT 10h             
    POP BX
    
    INC CX              ; X = X + 1 (Anda um pixel pra direita)
    DEC BX
    JNZ coluna          ; Repete até pintar toda a largura da linha atual
    
    POP BX              ; Recupera a altura restante
    POP CX              ; Volta o X para a esquerda
    INC DX              ; Y = Y + 1 (Desce uma linha)
    DEC BX
    JNZ linha           ; Repete até pintar todas as linhas (Altura)
    
    ; Restaura o contexto
    POP BX
    POP DI
    POP SI
    POP DX
    POP CX
fim_retangulo:
    RET

desenha_pause:
    ; Barra esquerda (Branca)
    MOV CX, 305         ; Centralizado no X (metade de 640)
    MOV DX, 220         ; Centralizado no Y (metade de 480)
    MOV SI, 10          ; Largura
    MOV DI, 40          ; Altura
    MOV AL, 15          ; Cor: 15 (Branco)
    CALL desenha_retangulo

    ; Barra direita (Branca)
    MOV CX, 325         ; 10 pixels de espaço entre as barras
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 15          
    CALL desenha_retangulo
    RET

apaga_pause:
    ; Apaga barra esquerda (Preta)
    MOV CX, 305
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0           ; Cor: 0 (preto - Fundo)
    CALL desenha_retangulo

    ; Apaga barra direita (Preta)
    MOV CX, 325
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0
    CALL desenha_retangulo
    RET

desenha_menu_quit:
    ; 1. Desenha a borda do menu (Branca)
    MOV CX, 220         ; X
    MOV DX, 180         ; Y
    MOV SI, 200         ; Largura
    MOV DI, 60          ; Altura
    MOV AL, 15          ; Cor 15 (Branco)
    CALL desenha_retangulo

    ; 2. Desenha o miolo do menu (preto)
    MOV CX, 225
    MOV DX, 185
    MOV SI, 190
    MOV DI, 50
    MOV AL, 0           ; Cor 0 (preto)
    CALL desenha_retangulo

    ; 3. Posiciona o cursor de texto da BIOS
    MOV AH, 02h
    MOV BH, 0           ; Página de vídeo
    MOV DH, 13          ; Linha (Y do texto)
    MOV DL, 36          ; Coluna (X do texto)
    INT 10h

    ; 4. Loop de impressão da string (Caracter por caracter)
    MOV BX, msg_sair
    
print_loop:
    MOV AL, [BX]        ; Pega o caractere atual da string
    CMP AL, 0           ; Verifica se é o terminador (0)
    JE fim_menu_saida   ; Se for zero, acabou a string
    
    MOV AH, 0Eh         ; Função Teletype da BIOS
    PUSH BX             ; Salva o ponteiro da string
    MOV BH, 0
    MOV BL, 14          ; Cor 14 (Amarelo) para o texto
    INT 10h
    POP BX              ; Restaura o ponteiro
    
    INC BX              ; Avança pro próximo caractere
    JMP print_loop

fim_menu_saida:
    RET

apaga_menu_quit:
    ; Apaga o menu pintando um retângulo preto por cima
    MOV CX, 220
    MOV DX, 180
    MOV SI, 200
    MOV DI, 60
    MOV AL, 0
    CALL desenha_retangulo
    RET

;-----------------------------------------------------------------------------
;função retângulo
; Parametros:
;	PUSH x1; PUSH y1; PUSH x2; PUSH y2; PUSH tam_x; CALL desenha_retangulo;  (x1+tam_x < 639, x1 > 0, y1 > 0, y1+(y2-y1) < 479, x2 == x1, y2 > y1, y2 < 479)
; 	cor definida na variavel cor
desenha_retangulo2:
		PUSH 	BP
		MOV	 	BP,SP
		PUSHf                        ;coloca os flags na pilha
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI

		mov		DI,[bp+12]		;resgata o valor da coordenada x1 para AX
		MOV		BX,[BP+10]   	;resgata o valor da coordenada y1 para BX
		MOV		DX,[BP+8]    	;resgata o valor da coordenada x2 para DX
		MOV		SI,[BP+6]    	;resgata o valor da coordenada y2 para SI
		MOV		cx,[BP+4]    	;resgata o valor do tamanho do retangulo em x para CX

loop_retangulo:
		;mov		byte[cor],branco_intenso
		mov		ax, di
		push	ax
		mov		ax, bx
		push	ax
		mov		ax, di
		push	ax
		mov		ax, si
		push	ax
		call 	line
		inc		di
		loop loop_retangulo
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		POP		BP
		RET		10

;-----------------------------------------------------------------------------
;função plot_xy
; Parametros:
;	PUSH x; PUSH y; CALL plot_xy;  (x<639, y<479)
; 	cor definida na variavel cor
plot_xy:
		PUSH	BP
		MOV		BP,SP
		PUSHf
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
	    MOV     AH,0Ch
	    MOV     AL,[cor]
	    MOV     BH,0
	    MOV     DX,479
		SUB		DX,[BP+4]
	    MOV     CX,[BP+6]
	    INT     10h
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		POP		BP
		RET		4

;-----------------------------------------------------------------------------
;função line
; Parametros:
;	PUSH x1; PUSH y1; PUSH x2; PUSH y2; CALL line;  (x<639, y<479)
line:
		PUSH	BP
		MOV		BP,SP
		PUSHf             		;coloca os flags na pilha
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		MOV		AX,[BP+10]   	;resgata os vALores das coordenadas
		MOV		BX,[BP+8]    	;resgata os vALores das coordenadas
		MOV		CX,[BP+6]    	;resgata os vALores das coordenadas
		MOV		DX,[BP+4]    	;resgata os vALores das coordenadas
		CMP		AX,CX
		JE		line2
		JB		line1
		XCHG	AX,CX
		XCHG	BX,DX
		JMP		line1
line2:							;deltax = 0
		CMP		BX,DX  			;Subtrai DX de BX
		JB		line3
		XCHG	BX,DX        	;troca os valores de BX e DX entre eles
line3:							;DX > BX
		PUSH	AX
		PUSH	BX
		CALL 	plot_xy
		CMP		BX,DX
		JNE		line31
		JMP		fim_line
line31:	INC		BX
		JMP		line3
;deltAX <>0
line1:
;Comparar módulos de deltax e deltay sabendo que CX>AX
	; CX > AX
		PUSH	CX
		SUB		CX,AX
		MOV		[deltAX],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		JA		line32
		NEG		DX
line32:		
		MOV		[deltay],DX
		POP		DX

		PUSH	AX
		MOV		AX,[deltAX]
		CMP		AX,[deltay]
		POP		AX
		JB		line5
; CX > AX e deltAX>deltay
		PUSH	CX
		SUB		CX,AX
		MOV		[deltAX],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,AX
line4:
		PUSH	AX
		PUSH	DX
		PUSH	SI
		SUB		SI,AX	;(x-x1)
		MOV		AX,[deltay]
		IMUL	SI
		MOV		SI,[deltAX]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 Subtrai
		CMP		DX,0
		JL		ar1
		ADD		AX,SI
		ADC		DX,0
		JMP		arc1
ar1:	SUB		AX,SI
		SBB		DX,0
arc1:
		IDIV	word [deltAX]
		ADD		AX,BX
		POP		SI
		PUSH	SI
		PUSH	AX
		CALL	plot_xy
		POP		DX
		POP		AX
		CMP		SI,CX
		JE		fim_line
		INC		SI
		JMP		line4

line5:	CMP		BX,DX
		JB 		line7
		XCHG	AX,CX
		XCHG	BX,DX
line7:
		PUSH	CX
		SUB		CX,AX
		MOV		[deltAX],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,BX
line6:
		PUSH	DX
		PUSH	SI
		PUSH	AX
		SUB		SI,BX	;(y-y1)
		MOV		AX,[deltAX]
		IMUL	SI
		MOV		SI,[deltay]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 subtrai
		CMP		DX,0
		JL		ar2
		ADD		AX,SI
		ADC		DX,0
		JMP		arc2
ar2:	SUB		AX,SI
		SBB		DX,0
arc2:
		IDIV	word [deltay]
		MOV		DI,AX
		POP		AX
		ADD		DI,AX
		POP		SI
		PUSH	DI
		PUSH	SI
		CALL	plot_xy
		POP		DX
		CMP		SI,DX
		JE		fim_line
		INC		SI
		JMP		line6

fim_line:
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		POP		BP
		RET		8
	